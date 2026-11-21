# Code

Code is an agent that works on a folder. You describe a change, a bug or a feature. The model reads files, edits them and runs commands, and you review what it does. Open it with <kbd>⌘</kbd> <kbd>2</kbd> or the **Code** button in the title bar.

<picture><source media="(prefers-color-scheme: dark)" srcset="images/code-obsidian.png"><source media="(prefers-color-scheme: light)" srcset="images/code-light.png"><img src="images/code-light.png" alt="Code working on a folder" /></picture>

Code uses a model you load in the title bar, the same way Chat does. Models of 14 billion parameters and up do better at coding work.

## Choose a folder

On the start screen, click **Choose a folder**. Code works inside that folder, and only there. Recent folders are listed below it. Each folder has its own sessions.

## Modes

The mode sets what Code may do without asking. Press <kbd>Shift</kbd> <kbd>Tab</kbd> to cycle through them, or pick one under the composer.

| Mode | What it does |
| --- | --- |
| **Plan** | Read-only. It looks at your code and proposes a plan. Edits and commands are refused. |
| **Manual** | Asks before every edit and command. |
| **Accept edits** | Edits apply. Commands ask. This is the default. |
| **Autopilot** | Runs everything in this folder without asking. |

Reading files, listing, searching and the task list never ask. Some commands always ask, even in autopilot: those that install packages, publish, delete in bulk, use the network or read secret files. Some commands never run in any mode, such as `sudo` and `shutdown`. Choose **Plan** or **Manual** for folders with sensitive files.

## What Code can do

Code has eight tools: list a folder, find files by name, search file contents, read a file, edit a file, write a file, run a command, and keep a task list. When it works, each step shows as a line in the transcript, such as *Read src/lib.rs* or *Searched for*, with a **+added** and **−removed** count for edits.

Commands run in your folder. A command is stopped after two minutes unless Code asks for longer, up to ten. If the same step fails three times in a row, Code stops and says so. After 50 steps in one turn, it stops and says *Stopped after 50 steps. Send a message to go on.*

## Approve a change

When a step needs your approval, a card asks *Run this command?*, *Create this file?* or *Make this edit?*, with the diff or the command. Choose **Run** or **Apply** to allow it, or **Deny**. To tell Code what to do instead, type in the feedback box before you choose **Deny**.

## Review changes

Click **Changed files** in the title bar to open the panel on the right. It lists the files Code changed in this session, each with its diff. *Files that Code changes show up here, ready to review.* shows until there is a change.

## Checkpoints and rewind

Before each turn, Code takes a snapshot of your folder. It keeps the snapshots in a private store in Ignis's data folder, not in your project, so it works in folders that are not git repositories and never touches your own `.git`. Folders such as `node_modules`, `target`, `dist` and `build`, and `*.gguf` files, are left out.

To go back, hover one of your messages and click **Rewind to here**. Your files return to how they were before that turn, and files Code created since are deleted.

## Sessions

Each folder keeps a list of sessions on the left. Start one with **New session**. Hover a session to **Rename session** or **Delete session**. Sessions are saved on this Mac. An empty list says *Sessions in this folder show up here.*

## Mention files with @

Type `@` in the composer to pick a file from the folder. Code adds its contents to your message. You can mention up to 8 files, and each is cut at 30,000 characters.

## Compaction

A long session can fill the model's context. Type `/compact` to ask the model to summarize the session so far. Code then continues from the summary. When a session reaches 85% of the context, Code compacts it by itself before the next turn.

## Terminal

Click **Terminal** in the title bar, or press <kbd>Ctrl</kbd> <kbd>`</kbd>, to open a shell in the project folder below the transcript. It is a normal shell. Commands you type there are not checked by the mode.

## Project instructions

If the folder has a file named `BOUNCER.md`, Code reads it into its instructions. Use it for notes on how to build, test and style the project. It is the same file Bouncer reads. The text is treated as notes, not as commands.

## Scheduled tasks

A scheduled task runs a prompt with the Code agent in one folder, on demand or on a schedule. Click **Scheduled** in the left rail, or on Code's start screen, to open Scheduled tasks. The header says *N waiting for you* when runs need you.

### Create a task

Click **New task**. The dialog is **New scheduled task**, or **Edit scheduled task** when you change one.

| Field | What it does |
| --- | --- |
| **Folder** | The folder the task works in. Click **Choose folder** to pick it. |
| **What to do** | The prompt. |
| **Name (optional)** | A name for the task. It defaults to one taken from the prompt. |
| **Mode** | **Plan**, **Manual**, **Accept edits** or **Autopilot**. These are the same modes as a Code session, and **Accept edits** is the default. See [Modes](#modes). |
| **When** | **On demand**, **Once**, **Daily** or **Repeat**. See below. |
| **Run in a separate worktree** | On by default. See below. |

**When** has four choices:

- **On demand**: the task runs only when you run it.
- **Once**: runs at a date and time you pick.
- **Daily**: runs at a time you pick, on the days of the week you pick. With no days chosen, it runs every day.
- **Repeat**: runs every N minutes.

With **Run in a separate worktree** on, each run starts from the last commit on its own branch, and your folder stays untouched until you merge. A folder that isn't a git repository is edited in place.

The footer says *Runs never commit. You review each one.* Click **Create** to save the task.

### Manage tasks

The list shows each task with its title, mode, folder, its schedule or **Paused**, the next run and the last run. Each task has these actions:

| Action | What it does |
| --- | --- |
| **Run now** | Starts a run right away. |
| **Edit** | Opens the task in the dialog. |
| **Pause** / **Resume** | Stops or restarts its schedule. |
| Trash icon | Deletes the task, after a confirmation. |

### When tasks run

Runs happen in the background service (`ignis`), so they run on time even when the app is closed, as [Rebound](rebound.md) routines do. To keep the service running, turn on **Start at login** in **Settings, Engine**.

- Runs use the model the service has loaded. With none loaded, the run fails with *No model is loaded. Load one in Ignis, then run this task again.*
- One task runs at a time.
- A task that came due while the service was off runs once when it's next running. Missed runs aren't repeated.
- When a run finishes, Ignis sends a notification, *Scheduled: <task name>*.

### Review a run

Each run shows its status and when it started. The status is **Running**, **Needs you**, **Done**, **Failed** or **Stopped**. Open a run to see its changed files, with the lines added and removed.

| Action | What it does |
| --- | --- |
| **Merge** | Applies the run's changes to your folder as staged changes. Nothing is committed. If a file has unstaged edits, Ignis asks you to stage, commit or stash them first. Conflicting files get conflict markers. |
| **Discard** | Removes the run's changes and its worktree. For a run without a worktree, it rewinds the folder. |
| **Open session** | Opens the run as a Code session. Each run is saved as an ordinary Code session for that folder. |
| **Stop** | Stops the run while it is running. |

### When a run needs you

Depending on the mode, a step can need your approval. The run then waits and shows **Needs you**, with the step, for example a command to run, and **Approve** and **Deny**. Ignis sends a notification, *A scheduled task needs you*. On Windows there are no notifications yet. The run waits until you answer.

If the service stops while a run is going, the run is marked stopped with *Ignis quit while this ran*.

### Where tasks are saved

Tasks and runs are saved in Ignis's data folder, in `code/scheduled.json`. Run worktrees are kept in Ignis's data folder under `rebound/worktrees`, on branches named `rebound/<id>`, until you merge or discard them.

## Related

- [Models](models.md)
- [Keyboard shortcuts](keyboard-shortcuts.md)
- [Privacy](privacy.md#what-code-can-run)
- [Claude Code](claude-code.md): use Claude Code itself with a local model.
