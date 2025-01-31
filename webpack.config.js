const webpack = require('webpack');

module.exports = {
    webpack: function (config, env) {
        // Add Babel plugin to handle private methods
        config.module.rules.push({
            test: /\.js$/,
            loader: 'babel-loader',
            exclude: /node_modules/,
            options: {
                presets: ['@babel/preset-env'],
                plugins: ['@babel/plugin-proposal-private-methods']
            }
        });
        return config;
    }
};
