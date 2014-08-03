# Backend

The Backend works together with Lychee and  miniLychee and allows photographers to generate flyers, upload photos and manage their settings.

## Installation

Make sure the following tools are installed on your system:

- `node` [Node.js](http://nodejs.org) v0.10 or later
- `npm` [Node Packaged Modules](https://www.npmjs.org)

After [installing Node.js](http://nodejs.org) you can use the following commands to install the dependencies and build miniLychee:

	npm install -g bower coffee-script grunt-cli
	npm install
	
## Configuration

1. Duplicate `config.sample.json` in `data/`
2. Name the copied file `config.json`
3. Open and fill the configuration and remove **all** comments

## Start

Use the following command to start the Backend:

	npm start
	
Open the Backend in your browser and follow the given steps. The first user will be the admin.