// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct ClaudeApprovalStrings {
    let title: String
    let hubDescription: String
    let toggle: String
    let explanation: String
    let newSessionsOnly: String
    let statusNotInstalled: String
    let statusInstalled: String
    let statusOtherCopy: String
    let statusUnreadable: String
    let install: String
    let update: String
    let remove: String
    let reviewTitle: String
    let reviewNote: String
    let confirmInstall: String
    let confirmRemove: String
    let cancel: String
    let foreignHooksFormat: String
    let socketTooLong: String
    let writeFailed: String
    let deny: String
    let always: String
    let allow: String
    let alwaysHelp: String
    let requestLabel: String
}

extension FeatureStrings {
    static func claudeApprovals(_ language: AppLanguage) -> ClaudeApprovalStrings {
        switch language {
        case .enUS: return .enUS
        case .ptBR: return .ptBR
        case .tr: return .tr
        case .ru: return .ru
        case .es: return .es
        case .sk: return .sk
        case .de: return .de
        case .fr: return .fr
        case .it: return .it
        case .ja: return .ja
        case .ko: return .ko
        case .uk: return .uk
        case .zhHans: return .zhHans
        case .zhTW: return .zhTW
        case .zhHK: return .zhHK
        }
    }
}

extension ClaudeApprovalStrings {
    static let enUS = ClaudeApprovalStrings(
        title: "Claude Code Approvals",
        hubDescription: "Answer Claude Code permission requests from the Dynamic Island with Deny, Always or Allow",
        toggle: "Ask in the Dynamic Island",
        explanation: "When Claude Code asks for permission, the island opens with the project, the tool and the command. The terminal prompt stays available, and a request nobody answers goes back to it.",
        newSessionsOnly: "Claude Code reads hooks when a session starts, so only sessions started after a change use it.",
        statusNotInstalled: "Not installed in Claude Code",
        statusInstalled: "Installed in Claude Code",
        statusOtherCopy: "Installed for another copy of Vorssaint",
        statusUnreadable: "~/.claude/settings.json is not valid JSON, so it is left untouched.",
        install: "Install…",
        update: "Update…",
        remove: "Remove…",
        reviewTitle: "Changes to ~/.claude/settings.json",
        reviewNote: "The current file is copied next to it first. Key order and spacing are normalized.",
        confirmInstall: "Install",
        confirmRemove: "Remove",
        cancel: "Cancel",
        foreignHooksFormat: "Another tool also answers permission requests: %@. Two answers at once are unpredictable, so turn one of them off.",
        socketTooLong: "The app’s support folder path is too long for a local socket, so approvals cannot run.",
        writeFailed: "~/.claude/settings.json could not be written.",
        deny: "Deny",
        always: "Always",
        allow: "Allow",
        alwaysHelp: "Allow, and add a rule so Claude Code stops asking for this",
        requestLabel: "Claude Code asks for permission")

    static let ptBR = ClaudeApprovalStrings(
        title: "Aprovações do Claude Code",
        hubDescription: "Responda aos pedidos de permissão do Claude Code na Dynamic Island com Negar, Sempre ou Permitir",
        toggle: "Perguntar na Dynamic Island",
        explanation: "Quando o Claude Code pede permissão, a ilha abre com o projeto, a ferramenta e o comando. O aviso do terminal continua disponível, e um pedido sem resposta volta para ele.",
        newSessionsOnly: "O Claude Code lê os hooks quando uma sessão começa, então só as sessões iniciadas depois de uma alteração a usam.",
        statusNotInstalled: "Não instalado no Claude Code",
        statusInstalled: "Instalado no Claude Code",
        statusOtherCopy: "Instalado para outra cópia do Vorssaint",
        statusUnreadable: "~/.claude/settings.json não é um JSON válido, então não é alterado.",
        install: "Instalar…",
        update: "Atualizar…",
        remove: "Remover…",
        reviewTitle: "Alterações em ~/.claude/settings.json",
        reviewNote: "O arquivo atual é copiado ao lado dele antes. A ordem das chaves e os espaços são normalizados.",
        confirmInstall: "Instalar",
        confirmRemove: "Remover",
        cancel: "Cancelar",
        foreignHooksFormat: "Outra ferramenta também responde aos pedidos de permissão: %@. Duas respostas ao mesmo tempo são imprevisíveis, então desative uma delas.",
        socketTooLong: "O caminho da pasta de suporte do app é longo demais para um socket local, então as aprovações não podem funcionar.",
        writeFailed: "Não foi possível gravar ~/.claude/settings.json.",
        deny: "Negar",
        always: "Sempre",
        allow: "Permitir",
        alwaysHelp: "Permitir e adicionar uma regra para o Claude Code não perguntar mais sobre isso",
        requestLabel: "O Claude Code pede permissão")

    static let tr = ClaudeApprovalStrings(
        title: "Claude Code Onayları",
        hubDescription: "Claude Code izin isteklerini Dynamic Island’dan Reddet, Her Zaman veya İzin Ver ile yanıtlayın",
        toggle: "Dynamic Island’da sor",
        explanation: "Claude Code izin istediğinde ada; proje, araç ve komutla açılır. Terminaldeki istem kullanılabilir kalır ve yanıtlanmayan bir istek ona geri döner.",
        newSessionsOnly: "Claude Code kancaları oturum başlarken okur, bu yüzden yalnızca değişiklikten sonra başlayan oturumlar bunu kullanır.",
        statusNotInstalled: "Claude Code’a kurulu değil",
        statusInstalled: "Claude Code’a kurulu",
        statusOtherCopy: "Vorssaint’in başka bir kopyası için kurulu",
        statusUnreadable: "~/.claude/settings.json geçerli bir JSON değil, bu yüzden değiştirilmez.",
        install: "Kur…",
        update: "Güncelle…",
        remove: "Kaldır…",
        reviewTitle: "~/.claude/settings.json dosyasındaki değişiklikler",
        reviewNote: "Mevcut dosya önce yanına kopyalanır. Anahtar sırası ve boşluklar düzenlenir.",
        confirmInstall: "Kur",
        confirmRemove: "Kaldır",
        cancel: "Vazgeç",
        foreignHooksFormat: "Başka bir araç da izin isteklerini yanıtlıyor: %@. Aynı anda iki yanıt öngörülemez, bu yüzden birini kapatın.",
        socketTooLong: "Uygulamanın destek klasörü yolu yerel bir soket için çok uzun, bu yüzden onaylar çalışamaz.",
        writeFailed: "~/.claude/settings.json yazılamadı.",
        deny: "Reddet",
        always: "Her Zaman",
        allow: "İzin Ver",
        alwaysHelp: "İzin ver ve Claude Code’un bunu bir daha sormaması için bir kural ekle",
        requestLabel: "Claude Code izin istiyor")

    static let ru = ClaudeApprovalStrings(
        title: "Разрешения Claude Code",
        hubDescription: "Отвечайте на запросы разрешений Claude Code в Dynamic Island: «Запретить», «Всегда» или «Разрешить»",
        toggle: "Спрашивать в Dynamic Island",
        explanation: "Когда Claude Code запрашивает разрешение, остров открывается с проектом, инструментом и командой. Запрос в терминале остаётся доступен, а запрос без ответа возвращается туда.",
        newSessionsOnly: "Claude Code читает хуки при запуске сеанса, поэтому изменение действует только в сеансах, начатых после него.",
        statusNotInstalled: "Не установлено в Claude Code",
        statusInstalled: "Установлено в Claude Code",
        statusOtherCopy: "Установлено для другой копии Vorssaint",
        statusUnreadable: "~/.claude/settings.json не является корректным JSON, поэтому файл не изменяется.",
        install: "Установить…",
        update: "Обновить…",
        remove: "Удалить…",
        reviewTitle: "Изменения в ~/.claude/settings.json",
        reviewNote: "Сначала текущий файл копируется рядом. Порядок ключей и отступы нормализуются.",
        confirmInstall: "Установить",
        confirmRemove: "Удалить",
        cancel: "Отменить",
        foreignHooksFormat: "Другой инструмент тоже отвечает на запросы разрешений: %@. Два ответа одновременно непредсказуемы, поэтому отключите один из них.",
        socketTooLong: "Путь к папке поддержки приложения слишком длинный для локального сокета, поэтому разрешения не работают.",
        writeFailed: "Не удалось записать ~/.claude/settings.json.",
        deny: "Запретить",
        always: "Всегда",
        allow: "Разрешить",
        alwaysHelp: "Разрешить и добавить правило, чтобы Claude Code больше не спрашивал об этом",
        requestLabel: "Claude Code запрашивает разрешение")

    static let es = ClaudeApprovalStrings(
        title: "Aprobaciones de Claude Code",
        hubDescription: "Responde a las solicitudes de permiso de Claude Code desde la Dynamic Island con Denegar, Siempre o Permitir",
        toggle: "Preguntar en la Dynamic Island",
        explanation: "Cuando Claude Code pide permiso, la isla se abre con el proyecto, la herramienta y el comando. El aviso del terminal sigue disponible, y una solicitud sin respuesta vuelve a él.",
        newSessionsOnly: "Claude Code lee los hooks al empezar una sesión, así que solo las sesiones iniciadas después de un cambio lo usan.",
        statusNotInstalled: "No instalado en Claude Code",
        statusInstalled: "Instalado en Claude Code",
        statusOtherCopy: "Instalado para otra copia de Vorssaint",
        statusUnreadable: "~/.claude/settings.json no es un JSON válido, así que no se modifica.",
        install: "Instalar…",
        update: "Actualizar…",
        remove: "Quitar…",
        reviewTitle: "Cambios en ~/.claude/settings.json",
        reviewNote: "Primero se copia el archivo actual a su lado. El orden de las claves y los espacios se normalizan.",
        confirmInstall: "Instalar",
        confirmRemove: "Quitar",
        cancel: "Cancelar",
        foreignHooksFormat: "Otra herramienta también responde a las solicitudes de permiso: %@. Dos respuestas a la vez son impredecibles, así que desactiva una de ellas.",
        socketTooLong: "La ruta de la carpeta de soporte de la app es demasiado larga para un socket local, así que las aprobaciones no pueden funcionar.",
        writeFailed: "No se pudo escribir ~/.claude/settings.json.",
        deny: "Denegar",
        always: "Siempre",
        allow: "Permitir",
        alwaysHelp: "Permitir y añadir una regla para que Claude Code deje de preguntar por esto",
        requestLabel: "Claude Code pide permiso")

    static let sk = ClaudeApprovalStrings(
        title: "Schválenia Claude Code",
        hubDescription: "Odpovedajte na žiadosti o povolenie Claude Code v Dynamic Island tlačidlami Zamietnuť, Vždy alebo Povoliť",
        toggle: "Pýtať sa v Dynamic Island",
        explanation: "Keď Claude Code žiada o povolenie, ostrov sa otvorí s projektom, nástrojom a príkazom. Výzva v termináli zostáva dostupná a nezodpovedaná žiadosť sa vráti do nej.",
        newSessionsOnly: "Claude Code načítava hooky pri spustení relácie, takže zmenu použijú len relácie spustené po nej.",
        statusNotInstalled: "Nie je nainštalované v Claude Code",
        statusInstalled: "Nainštalované v Claude Code",
        statusOtherCopy: "Nainštalované pre inú kópiu Vorssaint",
        statusUnreadable: "~/.claude/settings.json nie je platný JSON, preto sa nemení.",
        install: "Nainštalovať…",
        update: "Aktualizovať…",
        remove: "Odstrániť…",
        reviewTitle: "Zmeny v ~/.claude/settings.json",
        reviewNote: "Aktuálny súbor sa najprv skopíruje vedľa neho. Poradie kľúčov a medzery sa normalizujú.",
        confirmInstall: "Nainštalovať",
        confirmRemove: "Odstrániť",
        cancel: "Zrušiť",
        foreignHooksFormat: "Na žiadosti o povolenie odpovedá aj iný nástroj: %@. Dve odpovede naraz sú nepredvídateľné, preto jeden z nich vypnite.",
        socketTooLong: "Cesta k podpornému priečinku aplikácie je pre lokálny socket príliš dlhá, preto schválenia nemôžu fungovať.",
        writeFailed: "Súbor ~/.claude/settings.json sa nepodarilo zapísať.",
        deny: "Zamietnuť",
        always: "Vždy",
        allow: "Povoliť",
        alwaysHelp: "Povoliť a pridať pravidlo, aby sa Claude Code na toto už nepýtal",
        requestLabel: "Claude Code žiada o povolenie")

    static let de = ClaudeApprovalStrings(
        title: "Claude Code-Freigaben",
        hubDescription: "Berechtigungsanfragen von Claude Code in der Dynamic Island mit Ablehnen, Immer oder Erlauben beantworten",
        toggle: "In der Dynamic Island fragen",
        explanation: "Wenn Claude Code um Erlaubnis fragt, öffnet sich die Insel mit Projekt, Werkzeug und Befehl. Die Abfrage im Terminal bleibt verfügbar, und eine unbeantwortete Anfrage geht dorthin zurück.",
        newSessionsOnly: "Claude Code liest Hooks beim Start einer Sitzung, daher nutzen nur Sitzungen, die nach einer Änderung starten, sie.",
        statusNotInstalled: "Nicht in Claude Code installiert",
        statusInstalled: "In Claude Code installiert",
        statusOtherCopy: "Für eine andere Kopie von Vorssaint installiert",
        statusUnreadable: "~/.claude/settings.json ist kein gültiges JSON und bleibt daher unverändert.",
        install: "Installieren…",
        update: "Aktualisieren…",
        remove: "Entfernen…",
        reviewTitle: "Änderungen an ~/.claude/settings.json",
        reviewNote: "Die aktuelle Datei wird zuerst daneben kopiert. Schlüsselreihenfolge und Abstände werden vereinheitlicht.",
        confirmInstall: "Installieren",
        confirmRemove: "Entfernen",
        cancel: "Abbrechen",
        foreignHooksFormat: "Ein anderes Werkzeug beantwortet ebenfalls Berechtigungsanfragen: %@. Zwei Antworten gleichzeitig sind unvorhersehbar, schalte daher eines davon aus.",
        socketTooLong: "Der Pfad zum Support-Ordner der App ist für einen lokalen Socket zu lang, daher können Freigaben nicht laufen.",
        writeFailed: "~/.claude/settings.json konnte nicht geschrieben werden.",
        deny: "Ablehnen",
        always: "Immer",
        allow: "Erlauben",
        alwaysHelp: "Erlauben und eine Regel hinzufügen, damit Claude Code hierfür nicht mehr fragt",
        requestLabel: "Claude Code fragt um Erlaubnis")

    static let fr = ClaudeApprovalStrings(
        title: "Autorisations Claude Code",
        hubDescription: "Répondez aux demandes d’autorisation de Claude Code depuis la Dynamic Island avec Refuser, Toujours ou Autoriser",
        toggle: "Demander dans la Dynamic Island",
        explanation: "Quand Claude Code demande une autorisation, l’île s’ouvre avec le projet, l’outil et la commande. La demande du terminal reste disponible, et une demande sans réponse lui revient.",
        newSessionsOnly: "Claude Code lit les hooks au démarrage d’une session, donc seules les sessions lancées après un changement l’utilisent.",
        statusNotInstalled: "Non installé dans Claude Code",
        statusInstalled: "Installé dans Claude Code",
        statusOtherCopy: "Installé pour une autre copie de Vorssaint",
        statusUnreadable: "~/.claude/settings.json n’est pas un JSON valide, il n’est donc pas modifié.",
        install: "Installer…",
        update: "Mettre à jour…",
        remove: "Retirer…",
        reviewTitle: "Modifications de ~/.claude/settings.json",
        reviewNote: "Le fichier actuel est d’abord copié à côté. L’ordre des clés et les espaces sont normalisés.",
        confirmInstall: "Installer",
        confirmRemove: "Retirer",
        cancel: "Annuler",
        foreignHooksFormat: "Un autre outil répond aussi aux demandes d’autorisation : %@. Deux réponses à la fois sont imprévisibles, désactivez donc l’un des deux.",
        socketTooLong: "Le chemin du dossier de support de l’app est trop long pour un socket local, les autorisations ne peuvent donc pas fonctionner.",
        writeFailed: "Impossible d’écrire ~/.claude/settings.json.",
        deny: "Refuser",
        always: "Toujours",
        allow: "Autoriser",
        alwaysHelp: "Autoriser et ajouter une règle pour que Claude Code ne le demande plus",
        requestLabel: "Claude Code demande une autorisation")

    static let it = ClaudeApprovalStrings(
        title: "Approvazioni di Claude Code",
        hubDescription: "Rispondi alle richieste di autorizzazione di Claude Code dalla Dynamic Island con Nega, Sempre o Consenti",
        toggle: "Chiedi nella Dynamic Island",
        explanation: "Quando Claude Code chiede un’autorizzazione, l’isola si apre con il progetto, lo strumento e il comando. La richiesta nel terminale resta disponibile, e una richiesta senza risposta torna lì.",
        newSessionsOnly: "Claude Code legge gli hook all’avvio di una sessione, quindi lo usano solo le sessioni avviate dopo una modifica.",
        statusNotInstalled: "Non installato in Claude Code",
        statusInstalled: "Installato in Claude Code",
        statusOtherCopy: "Installato per un’altra copia di Vorssaint",
        statusUnreadable: "~/.claude/settings.json non è un JSON valido, quindi non viene modificato.",
        install: "Installa…",
        update: "Aggiorna…",
        remove: "Rimuovi…",
        reviewTitle: "Modifiche a ~/.claude/settings.json",
        reviewNote: "Il file attuale viene prima copiato accanto. L’ordine delle chiavi e gli spazi vengono normalizzati.",
        confirmInstall: "Installa",
        confirmRemove: "Rimuovi",
        cancel: "Annulla",
        foreignHooksFormat: "Anche un altro strumento risponde alle richieste di autorizzazione: %@. Due risposte insieme sono imprevedibili, quindi disattivane uno.",
        socketTooLong: "Il percorso della cartella di supporto dell’app è troppo lungo per un socket locale, quindi le approvazioni non possono funzionare.",
        writeFailed: "Impossibile scrivere ~/.claude/settings.json.",
        deny: "Nega",
        always: "Sempre",
        allow: "Consenti",
        alwaysHelp: "Consenti e aggiungi una regola perché Claude Code non lo chieda più",
        requestLabel: "Claude Code chiede un’autorizzazione")

    static let ja = ClaudeApprovalStrings(
        title: "Claude Code の承認",
        hubDescription: "Claude Code の許可リクエストに Dynamic Island から「拒否」「常に許可」「許可」で応答します",
        toggle: "Dynamic Island で確認",
        explanation: "Claude Code が許可を求めると、プロジェクト、ツール、コマンドを表示してアイランドが開きます。ターミナルの確認もそのまま使え、応答のないリクエストはターミナルに戻ります。",
        newSessionsOnly: "Claude Code はセッション開始時にフックを読み込むため、変更後に開始したセッションでのみ使われます。",
        statusNotInstalled: "Claude Code にインストールされていません",
        statusInstalled: "Claude Code にインストール済み",
        statusOtherCopy: "別の Vorssaint 用にインストール済み",
        statusUnreadable: "~/.claude/settings.json が有効な JSON ではないため、変更しません。",
        install: "インストール…",
        update: "更新…",
        remove: "削除…",
        reviewTitle: "~/.claude/settings.json の変更内容",
        reviewNote: "先に現在のファイルを同じ場所にコピーします。キーの順序と空白は整えられます。",
        confirmInstall: "インストール",
        confirmRemove: "削除",
        cancel: "キャンセル",
        foreignHooksFormat: "別のツールも許可リクエストに応答しています: %@。同時に 2 つの応答があると結果が予測できないため、どちらかをオフにしてください。",
        socketTooLong: "アプリのサポートフォルダのパスがローカルソケットには長すぎるため、承認を使用できません。",
        writeFailed: "~/.claude/settings.json に書き込めませんでした。",
        deny: "拒否",
        always: "常に許可",
        allow: "許可",
        alwaysHelp: "許可し、Claude Code が今後これを確認しないようにルールを追加します",
        requestLabel: "Claude Code が許可を求めています")

    static let ko = ClaudeApprovalStrings(
        title: "Claude Code 승인",
        hubDescription: "Dynamic Island에서 거부, 항상, 허용으로 Claude Code의 권한 요청에 응답합니다",
        toggle: "Dynamic Island에서 묻기",
        explanation: "Claude Code가 권한을 요청하면 프로젝트, 도구, 명령과 함께 아일랜드가 열립니다. 터미널의 확인 창도 그대로 사용할 수 있으며, 응답하지 않은 요청은 터미널로 돌아갑니다.",
        newSessionsOnly: "Claude Code는 세션을 시작할 때 훅을 읽으므로, 변경 후 시작한 세션에서만 사용됩니다.",
        statusNotInstalled: "Claude Code에 설치되지 않음",
        statusInstalled: "Claude Code에 설치됨",
        statusOtherCopy: "다른 Vorssaint 사본용으로 설치됨",
        statusUnreadable: "~/.claude/settings.json이 올바른 JSON이 아니므로 변경하지 않습니다.",
        install: "설치…",
        update: "업데이트…",
        remove: "제거…",
        reviewTitle: "~/.claude/settings.json 변경 사항",
        reviewNote: "먼저 현재 파일을 같은 위치에 복사합니다. 키 순서와 공백은 정리됩니다.",
        confirmInstall: "설치",
        confirmRemove: "제거",
        cancel: "취소",
        foreignHooksFormat: "다른 도구도 권한 요청에 응답하고 있습니다: %@. 두 응답이 동시에 오면 결과를 예측할 수 없으므로 하나를 끄세요.",
        socketTooLong: "앱 지원 폴더 경로가 로컬 소켓에 너무 길어 승인을 사용할 수 없습니다.",
        writeFailed: "~/.claude/settings.json에 쓸 수 없습니다.",
        deny: "거부",
        always: "항상",
        allow: "허용",
        alwaysHelp: "허용하고 Claude Code가 이 항목을 더 묻지 않도록 규칙을 추가합니다",
        requestLabel: "Claude Code가 권한을 요청합니다")

    static let uk = ClaudeApprovalStrings(
        title: "Дозволи Claude Code",
        hubDescription: "Відповідайте на запити дозволів Claude Code у Dynamic Island: «Заборонити», «Завжди» або «Дозволити»",
        toggle: "Питати в Dynamic Island",
        explanation: "Коли Claude Code просить дозвіл, острів відкривається з проєктом, інструментом і командою. Запит у терміналі залишається доступним, а запит без відповіді повертається туди.",
        newSessionsOnly: "Claude Code читає хуки під час запуску сеансу, тому зміна діє лише в сеансах, розпочатих після неї.",
        statusNotInstalled: "Не встановлено в Claude Code",
        statusInstalled: "Встановлено в Claude Code",
        statusOtherCopy: "Встановлено для іншої копії Vorssaint",
        statusUnreadable: "~/.claude/settings.json не є коректним JSON, тому файл не змінюється.",
        install: "Встановити…",
        update: "Оновити…",
        remove: "Вилучити…",
        reviewTitle: "Зміни в ~/.claude/settings.json",
        reviewNote: "Спершу поточний файл копіюється поруч. Порядок ключів і відступи впорядковуються.",
        confirmInstall: "Встановити",
        confirmRemove: "Вилучити",
        cancel: "Скасувати",
        foreignHooksFormat: "Інший інструмент теж відповідає на запити дозволів: %@. Дві відповіді одночасно непередбачувані, тому вимкніть один із них.",
        socketTooLong: "Шлях до теки підтримки застосунку задовгий для локального сокета, тому дозволи не працюють.",
        writeFailed: "Не вдалося записати ~/.claude/settings.json.",
        deny: "Заборонити",
        always: "Завжди",
        allow: "Дозволити",
        alwaysHelp: "Дозволити й додати правило, щоб Claude Code більше не питав про це",
        requestLabel: "Claude Code просить дозвіл")

    static let zhHans = ClaudeApprovalStrings(
        title: "Claude Code 授权",
        hubDescription: "在灵动岛中以“拒绝”“始终允许”或“允许”回应 Claude Code 的权限请求",
        toggle: "在灵动岛中询问",
        explanation: "Claude Code 请求权限时，灵动岛会打开并显示项目、工具和命令。终端中的提示仍然可用，无人回应的请求会交还给终端。",
        newSessionsOnly: "Claude Code 在会话开始时读取钩子，因此只有更改后开始的会话才会使用。",
        statusNotInstalled: "未安装到 Claude Code",
        statusInstalled: "已安装到 Claude Code",
        statusOtherCopy: "已为另一份 Vorssaint 安装",
        statusUnreadable: "~/.claude/settings.json 不是有效的 JSON，因此不会修改。",
        install: "安装…",
        update: "更新…",
        remove: "移除…",
        reviewTitle: "对 ~/.claude/settings.json 的更改",
        reviewNote: "会先将当前文件复制到同一位置。键的顺序和空白会被规范化。",
        confirmInstall: "安装",
        confirmRemove: "移除",
        cancel: "取消",
        foreignHooksFormat: "另一个工具也在回应权限请求：%@。同时出现两个回应会导致结果不可预测，请关闭其中一个。",
        socketTooLong: "App 支持文件夹的路径对本地套接字来说太长，因此无法使用授权。",
        writeFailed: "无法写入 ~/.claude/settings.json。",
        deny: "拒绝",
        always: "始终允许",
        allow: "允许",
        alwaysHelp: "允许并添加规则，让 Claude Code 不再询问此项",
        requestLabel: "Claude Code 请求权限")

    static let zhTW = ClaudeApprovalStrings(
        title: "Claude Code 授權",
        hubDescription: "在動態島中以「拒絕」「永遠允許」或「允許」回應 Claude Code 的權限要求",
        toggle: "在動態島中詢問",
        explanation: "Claude Code 要求權限時，動態島會打開並顯示專案、工具和指令。終端機中的提示仍可使用，沒有回應的要求會交回終端機。",
        newSessionsOnly: "Claude Code 會在工作階段開始時讀取掛鉤，因此只有變更後開始的工作階段才會使用。",
        statusNotInstalled: "未安裝到 Claude Code",
        statusInstalled: "已安裝到 Claude Code",
        statusOtherCopy: "已為另一份 Vorssaint 安裝",
        statusUnreadable: "~/.claude/settings.json 不是有效的 JSON，因此不會修改。",
        install: "安裝…",
        update: "更新…",
        remove: "移除…",
        reviewTitle: "對 ~/.claude/settings.json 的變更",
        reviewNote: "會先將目前的檔案複製到同一位置。鍵的順序和空白會被標準化。",
        confirmInstall: "安裝",
        confirmRemove: "移除",
        cancel: "取消",
        foreignHooksFormat: "另一個工具也在回應權限要求：%@。同時出現兩個回應會讓結果無法預測，請關閉其中一個。",
        socketTooLong: "App 支援檔案夾的路徑對本機通訊端來說太長，因此無法使用授權。",
        writeFailed: "無法寫入 ~/.claude/settings.json。",
        deny: "拒絕",
        always: "永遠允許",
        allow: "允許",
        alwaysHelp: "允許並新增規則，讓 Claude Code 不再詢問此項",
        requestLabel: "Claude Code 要求權限")

    static let zhHK = ClaudeApprovalStrings(
        title: "Claude Code 授權",
        hubDescription: "在動態島中以「拒絕」「永遠允許」或「允許」回應 Claude Code 的權限要求",
        toggle: "在動態島中詢問",
        explanation: "Claude Code 要求權限時，動態島會打開並顯示項目、工具和指令。終端機中的提示仍可使用，沒有回應的要求會交回終端機。",
        newSessionsOnly: "Claude Code 會在工作階段開始時讀取掛鈎，因此只有變更後開始的工作階段才會使用。",
        statusNotInstalled: "未安裝到 Claude Code",
        statusInstalled: "已安裝到 Claude Code",
        statusOtherCopy: "已為另一份 Vorssaint 安裝",
        statusUnreadable: "~/.claude/settings.json 不是有效的 JSON，因此不會修改。",
        install: "安裝…",
        update: "更新…",
        remove: "移除…",
        reviewTitle: "對 ~/.claude/settings.json 的變更",
        reviewNote: "會先將目前的檔案複製到同一位置。鍵的次序和空白會被標準化。",
        confirmInstall: "安裝",
        confirmRemove: "移除",
        cancel: "取消",
        foreignHooksFormat: "另一個工具也在回應權限要求：%@。同時出現兩個回應會令結果無法預測，請關閉其中一個。",
        socketTooLong: "App 支援資料夾的路徑對本機通訊端來說太長，因此無法使用授權。",
        writeFailed: "無法寫入 ~/.claude/settings.json。",
        deny: "拒絕",
        always: "永遠允許",
        allow: "允許",
        alwaysHelp: "允許並新增規則，令 Claude Code 不再詢問此項",
        requestLabel: "Claude Code 要求權限")
}
