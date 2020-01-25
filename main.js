const core = require('@actions/core');
const github = require('@actions/github');
const exec = require('@actions/exec');
const io = require('@actions/io');
const tc = require('@actions/tool-cache');

async function installOnWindows(nimversion) {
  // Install mingw
  let
    // MINGW_FILE = "i686-8.1.0-release-posix-dwarf-rt_v6-rev0.7z"
    MINGW_URL = "https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/8.1.0/threads-posix/dwarf/${MINGW_FILE}"
    MINGW_DIR = "mingw32"
  if (platform.arch === "x64" || platform.arch === "arm64") {
    // MINGW_FILE = "x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z"
    MINGW_URL = "https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/${MINGW_FILE}"
    MINGW_DIR = "mingw64"
  }
  const mingw_path = await tc.downloadTool(MINGW_URL);
  await exec.exec('7z', ['x', '-y', '-bd', mingw_path]);
  await io.mkdirP('/c/custom');
  await io.mv(MINGW_DIR, '/c/custom');
  core.addPath('/c/custom/' + MINGW_DIR + '/bin');

  // Build nim
  BRANCH = 'v' + nimversion
  await io.mkdirP('NimBinaries');
  await exec.exec('git', ['clone', '-b', BRANCH])
}

async function installWithChoosenim(nimversion) {
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  let env = Object.assign({}, process.env, {'CHOOSENIM_NO_ANALYTICS': '1'});
  await exec.exec('sh', [choosenim_path, '-y'], {env});
  const newpath = process.env.HOME + '/.nimble/bin';
  core.addPath(newpath);
  env = Object.assign({}, env, {'PATH': newpath + ':' + env.PATH});
  await exec.exec('choosenim', [nimversion], {env});
}

async function main() {
  const nimversion = core.getInput('nimversion');
  if (process.platform === 'win32') {
    await installOnWindows(nimversion);
  } else {
    await installWithChoosenim(nimversion);
  }
}


main().catch((err) => {
  core.setFailed(err.message);
})
