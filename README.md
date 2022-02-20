# vsdevenv-shell v1

[![test vsdevenv-shell](https://github.com/humbletim/vsdevenv-shell/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/humbletim/vsdevenv-shell/actions/workflows/ci.yml)

This action enables individual job steps to be executed from within a [Visual Studio Developer Command Prompt](https://docs.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2019) environment.

Similar to [other available](#See-also) Visual Studio actions, it is referenced into a workflow via `uses`. However, by design it _does not_ modify the global CI/CD environment, so instead it can and must be selectively applied to individual build steps as a custom `shell`:

Conceptual example:

```diff
  - name: my build step
- - shell: bash
+ - shell: vsdevenv x64 bash {0}
    run: |
-     echo "stock environment"
+     echo "stock environment + visual studio dev tools"
```

The shell integration pattern is: `shell: vsdevenv <arch> <subshell> {0}` (and the trailing "{0}" is required -- it's part of how GitHub Actions detects use of [Custom Shells](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#custom-shell) in general).

- **arch** can be `x64` (`amd64`), `x86`, `arm`, or `arm64` (see Microsoft [vsdevcmd.bat](https://docs.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2019#target-architecture-and-host-architecture) documentation)
- **subshell** can be `bash`, `cmd`, `pwsh`, `powershell`

## A more detailed example

_note: if new to GitHub Actions please see GitHub Help Documentation [Quickstart](https://docs.github.com/en/actions/quickstart) or [Creating a workflow file](https://docs.github.com/en/actions/using-workflows#creating-a-workflow-file)._

```yaml
name: test vsdevenv-shell integration
jobs:
  main:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - uses: humbletim/vsdevenv-shell@v1

      - name: regular build step
        shell: bash
        run: |
          echo "clean job environment (no dev tools)"
          echo "$(env | wc -l) environment variables defined"

      - name: build step executed within x64 Native Developer Tools env
        shell: vsdevenv x64 bash {0}
        run: |
          echo "$(env | wc -l) environment variables defined"
          cl.exe # <-- (as specified) cl.exe is only available to this step

      - name: regular build step
        shell: bash
        run: |
          echo "clean job environment (no dev tools)"
          echo "$(env | wc -l) environment variables defined"
```

For additional examples please see this action's [.github/workflow/ci.yml](.github/workflow/ci.yml) integration tests.

### See also:
- [Visual Studio Developer Command Prompt](https://docs.microsoft.com/en-us/visualstudio/ide/reference/command-prompt-powershell?view=vs-2019)
- [actions/setup-vs-dev-environment](https://github.com/marketplace/actions/setup-vs-dev-environment)
- [actions/enable-developer-command-prompt](https://github.com/marketplace/actions/enable-developer-command-prompt)
- [actions/visual-studio-shell](https://github.com/marketplace/actions/visual-studio-shell)
- [actions/setup-msvc-developer-command-prompt](https://github.com/marketplace/actions/setup-msvc-developer-command-prompt)
