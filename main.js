const core = require('@actions/core');
const exec = require('@actions/exec');
const tc = require('@actions/tool-cache');
const os = require('os');

async function installWithChoosenim(nimversion) {
  // Install choosenim
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  let env = Object.assign({}, process.env, {
    'CHOOSENIM_NO_ANALYTICS': '1',
    'CHOOSENIM_CHOOSE_VERSION': nimversion,
  });
  await exec.exec('sh', [choosenim_path, '-y'], {env});

  // Add nimble/bin to PATH
  const newpath = os.homedir() + '/.nimble/bin';
  core.addPath(newpath);
  env = Object.assign({}, env, {'PATH': newpath + ':' + env.PATH});

  // Run choosenim to install a version of nim
  await exec.exec('choosenim', [nimversion], {env});
}

async function main() {
  const nimversion = core.getInput('nimversion');
  await installWithChoosenim(nimversion);
}

main().catch((err) => {
  core.setFailed(err.message);
})
