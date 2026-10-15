// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Darwin
import Foundation

/// The `codex` processes running now, read from the kernel on demand and
/// never kept. Codex writes no pid anywhere, but a running session holds its
/// rollout open, which is what ties a process to its session.
enum AgentCodexProcesses {
    static func running() -> [AgentSessionProcess] {
        let estimated = max(1, Int(proc_listallpids(nil, 0)))
        var pids = [pid_t](repeating: 0, count: estimated + 32)
        let count = pids.withUnsafeMutableBytes { proc_listallpids($0.baseAddress, Int32($0.count)) }
        guard count > 0 else { return [] }
        return pids.prefix(min(Int(count), pids.count)).compactMap { pid in
            var path = [CChar](repeating: 0, count: Int(MAXPATHLEN) * 4)
            var info = proc_bsdinfo()
            var vnode = proc_vnodepathinfo()
            guard pid > 0, proc_pidpath(pid, &path, UInt32(path.count)) > 0,
                  // The npm package runs a native binary named codex too.
                  (String(cString: path) as NSString).lastPathComponent == "codex",
                  proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, Int32(MemoryLayout<proc_bsdinfo>.size)) > 0
            else { return nil }
            let cwd = proc_pidinfo(pid, PROC_PIDVNODEPATHINFO, 0, &vnode, Int32(MemoryLayout<proc_vnodepathinfo>.size)) > 0
                ? withUnsafeBytes(of: vnode.pvi_cdir.vip_path) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
                : nil
            let started = Date(timeIntervalSince1970: TimeInterval(info.pbi_start_tvsec) + TimeInterval(info.pbi_start_tvusec) / 1e6)
            return AgentSessionProcess(pid: pid, cwd: cwd, started: started, rollouts: openRollouts(of: pid))
        }
    }

    /// Every rollout some running `codex` holds open, in standard form.
    static func heldRollouts() -> Set<String> {
        running().reduce(into: Set<String>()) { $0.formUnion($1.rollouts) }
    }

    /// The `.jsonl` files a process holds open under a `.codex` folder.
    private static func openRollouts(of pid: pid_t) -> Set<String> {
        let size = proc_pidinfo(pid, PROC_PIDLISTFDS, 0, nil, 0)
        guard size > 0 else { return [] }
        let stride = MemoryLayout<proc_fdinfo>.stride
        var fds = [proc_fdinfo](repeating: proc_fdinfo(), count: Int(size) / stride + 8)
        let filled = fds.withUnsafeMutableBytes { proc_pidinfo(pid, PROC_PIDLISTFDS, 0, $0.baseAddress, Int32($0.count)) }
        guard filled > 0 else { return [] }
        var paths: Set<String> = []
        for fd in fds.prefix(Int(filled) / stride) where fd.proc_fdtype == UInt32(PROX_FDTYPE_VNODE) {
            var info = vnode_fdinfowithpath()
            let wanted = Int32(MemoryLayout<vnode_fdinfowithpath>.size)
            guard proc_pidfdinfo(pid, fd.proc_fd, PROC_PIDFDVNODEPATHINFO, &info, wanted) == wanted else { continue }
            let path = withUnsafeBytes(of: info.pvip.vip_path) { String(cString: $0.bindMemory(to: CChar.self).baseAddress!) }
            if path.hasSuffix(".jsonl"), path.contains("/.codex/") { paths.insert((path as NSString).standardizingPath) }
        }
        return paths
    }
}
