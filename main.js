const core = require('@actions/core');
const exec = require('@actions/exec');
const tc = require('@actions/tool-cache');
const os = require('os');
const fs = require('fs')

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach( f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? 
      walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
};

async function installWithChoosenim(nimversion) {
  // Install choosenim
  const choosenim_path = await tc.downloadTool('https://nim-lang.org/choosenim/init.sh');
  let env = Object.assign({}, process.env, {
    'CHOOSENIM_NO_ANALYTICS': '1',
  });
  await exec.exec('sh', [choosenim_path, '-y'], {env});

  // Add nimble/bin to PATH
  const newpath = os.homedir() + '/.nimble/bin';
  core.addPath(newpath);
  env = Object.assign({}, env, {'PATH': newpath + ':' + env.PATH});

  // Workaround for choosenim issue #199
  if (process.env.TEMP) {
    // On Windows, delete all the dlls
    walkDir(process.env.TEMP, filepath => {
      if (filepath.endsWith(".dll")) {
        fs.unlinkSync(filepath);
      }
    })
  }

  // Run choosenim to install a version of nim
  await exec.exec('choosenim', [nimversion, '--firstInstall'], {env});
}

async function main() {
  const nimversion = core.getInput('nimversion');
  await installWithChoosenim(nimversion);
}

main().catch((err) => {
  core.setFailed(err.message);
})
