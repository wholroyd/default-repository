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

- `build` - Build customizations (msbuild/psake/fake/albacore/make/etc) scripts
- `dist` - Build outputs go here (nupkgs/dlls/pdbs/static site content/rpm/deb/etc)
- `docs` - Documentation stuff, markdown files, help files etc.
- `lib` - Things that do not or can **NEVER** exist in a package
- `samples` - Sample projects
- `src` - Main projects (required)
- `tests` - Test projects (required)

### Breakdown of files

- `actions.cmd` - Bootstrap the build for Windows (optional)
- `actions.sh` - Bootstrap the build for \*nix (required)

Some environment variables to set up first...

```
# When doing 'create'
$DOCKER_TEAM
#DOCKER_REPO

# When doing 'publish'
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
  build             ...package restoration and a compilation
  test              ...all tests in order of unit, integration, and functional
  create            ...a Docker image
  publish           ...a Docker image
  deploy            ...to service fabric

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
