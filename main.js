const core = require('@actions/core');
const github = require('@actions/github');
const exec = require('@actions/exec');
const io = require('@actions/io');
const tc = require('@actions/tool-cache');

async function installOnWindows(nimversion) {

}

async function installWithChoosenim(nimversion) {
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  await exec.exec('sh', [choosenim_path, '-y'], {
    env: {'CHOOSENIM_NO_ANALYTICS': '1'},
  });
  await exec.exec('choosenim', [nimversion]);
}

try {
  const nimversion = core.getInput('nimversion');
  if (process.platform === 'win32') {
    await installOnWindows(nimversion);
  } else {
    await installWithChoosenim(nimversion);
  }
} catch (error) {
  core.setFailed(error.message);
}
