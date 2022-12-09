import fs from 'fs/promises'
import package_ from '../package.json'
import * as Path from 'path'

async function main() {
    var {version} = package_
    var data = {version, updated: new Date()}
    // Workaround for screwy service-worker update issues. The old updater detects a version change and is now refreshing before service-worker reloads and clears the cache, reviving our old friend the infinite-refresh bug. Workaround: fake out the version so we don't detect an update right away.
    if (version === '1.1.5') {
      data.version = '1.1.4';
    }
    var text = JSON.stringify(data, undefined, 2);
    await Promise.all([
        await fs.mkdir(Path.join(__dirname, '../.tmp'), {recursive: true}),
        await fs.mkdir(Path.join(__dirname, '../dist'), {recursive: true}),
    ])
    await Promise.all([
        fs.writeFile(Path.join(__dirname, '../.tmp/version.json'), text),
        fs.writeFile(Path.join(__dirname, '../dist/version.json'), text),
    ])
}
main().catch(e => {
    console.error(e)
    process.exit(1)
})