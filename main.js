const core = require('@actions/core');
const github = require('@actions/github');
const exec = require('@actions/exec');
const io = require('@actions/io');
const tc = require('@actions/tool-cache');

async function installOnWindows(nimversion) {
  await 1;
}

async function installWithChoosenim(nimversion) {
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  let env = Object.assign({}, process.env, {'CHOOSENIM_NO_ANALYTICS': '1'});
  await exec.exec('sh', [choosenim_path, '-y'], {env});
  core.addPath(process.env.HOME + '/.nimble/bin');
  await exec.exec('choosenim', [nimversion]);
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
