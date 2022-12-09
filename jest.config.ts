import {Config} from 'jest'

const config: Config = {
    preset: 'ts-jest',
    testEnvironment: 'node',
    testMatch: ["<rootDir>/tests/**/*.test.*"],
    // https://stackoverflow.com/questions/58613492/how-to-resolve-cannot-use-import-statement-outside-a-module-in-jest
    transform: {
        '^.+\\.(ts|tsx)?$': 'ts-jest',
        "^.+\\.(js|jsx)$": "babel-jest",
        "^.+\\.(html)$": "<rootDir>/tests/jest-raw-loader.js",
    },
    moduleNameMapper: {
        // load the view files
        "^bundle-text:(.+)$": "$1",
    }
}
export default config