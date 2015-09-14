# Default Repository

This is an example of a default Git repository that has a known hierarchy so
that continuous integration and continuous deployment automation can find what
it needs to in order to perform its job efficiently.

The idea is that this standardization allows anyone to understand the repository
as well as be able to trigger compilation, tests, and builds of a project using
the same set of instructions.

## Hierarchy

```
$/
  build/
  dist/
  docs/
  lib/
  samples/
  src/
  tests/
  .gitignore
  actions.cmd
  actions.sh
  README.md
```
### Breakdown of directories

- `build` - Build customizations (custom msbuild files/psake/fake/albacore/make/etc) scripts
- `dist` - Build outputs go here. Doing a actions.cmd/actions.sh generates artifacts here (nupkgs, dlls, pdbs, etc.)
- `docs` - Documentation stuff, markdown files, help files etc.
- `lib` - Things that can **NEVER** exist in a package
- `samples` - Sample projects (optional)
- `src` - Main projects (the product code)
- `tests` - Test projects

### Breakdown of files

- `actions.cmd` - Bootstrap the build for Windows (optional)
- `actions.sh` - Bootstrap the build for \*nix

Some environment variables to set up first...

```
# When doing 'create'
$DOCKER_TEAM
#DOCKER_REPO

# When doing 'deploy'
$DOCKER_TEAM
#DOCKER_REPO
$DOCKER_USERNAME
$DOCKER_PASSWORD
$DOCKER_EMAIL
```

Using the actions.sh/actions.cmd script...

```
Usage: ./actions.sh [OPTION] (ARGS)
  OPTION            Performs...
  ----------------  ----------------------------------------------------------
  build             ...a compilation, if required
  test              ...all tests in order of unit, integration, and functional
  create            ...a Docker image
  deploy            ...a Docker image

  universe          ...in order the options: build, test, docker, deploy
  galaxy            ...in order the options: build, test, docker

The following values are required for the given commands:

  ./actions.sh create [team] [repo]                                 ...or set:
    \$DOCKER_TEAM
    \$DOCKER_REPO

  ./actions.sh deploy [team] [repo] [username] [password] [email]   ...or set:
    \$DOCKER_TEAM
    \$DOCKER_REPO
    \$DOCKER_USERNAME
    \$DOCKER_PASSWORD
    \$DOCKER_EMAIL
```
