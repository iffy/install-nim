const core = require('@actions/core');
const exec = require('@actions/exec');
const tc = require('@actions/tool-cache');
const os = require('os');

async function installWithChoosenim(nimversion) {
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  const newpath = os.homedir() + '/.nimble/bin';
  core.addPath(newpath);
  let env = Object.assign({}, process.env, {'CHOOSENIM_NO_ANALYTICS': '1'});
  env = Object.assign({}, env, {'PATH': newpath + ':' + env.PATH});

  await exec.exec('sh', [choosenim_path, '-y'], {env});
  await exec.exec('choosenim', [nimversion], {env});
}

async function main() {
  const nimversion = core.getInput('nimversion');
  await installWithChoosenim(nimversion);
}

main().catch((err) => {
  core.setFailed(err.message);
})
