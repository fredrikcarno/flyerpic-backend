# Backend

The Backend works together with Lychee and  miniLychee and allows photographers to generate flyers, upload photos and manage their settings.

## Installation

Make sure the following tools are installed on your system:

- `node` [Node.js](http://nodejs.org) v0.10 or later
- `npm` [Node Packaged Modules](https://www.npmjs.org)

After [installing Node.js](http://nodejs.org) you can use the following commands to install the dependencies and build miniLychee:

	npm install -g bower coffee-script grunt-cli;
	npm install;
	
## Configuration

1. Duplicate `config.sample.json` in `data/`
2. Name the copied file `config.json`
3. Open and fill the configuration and remove **all** comments

## Start

Use the following command to start the Backend:

	npm start
	
Open the Backend in your browser and follow the given steps. The first user will be the admin.

## Build Flyers

Build the flyers with the following commands:

	cd flyers/01/;
	npm install;
	bower install;
	gulp;

## Database

The Backend creates a table called `lychee_users` with the following fields:

| Field | Description |
|:-----------|:------------|
| `id` |  |
| `type` | "photographer" or "admin" |
| `username` | Username of the user |
| `password` | Password of the user hashed with MD5 |
| `name` | Name of the user |
| `description` | Optional description |
| `primarymail` | This paypal-mail will get 100% - `percentperprice` of the `priceperalbum` or `priceperphoto` |
| `secondarymail` | This paypal-mail will get the `percentperprice` of the `priceperalbum` or `priceperphoto` |
| `helpmail` | This mail will be shown in the footer of each flyer |
| `avatar` | URL (starting with `http://`) to the avatar-image of the photographer |
| `background` | URL (starting with `http://`) to the background-image of the photographer for the flyer |
| `service` | "paypal" |
| `currencycode` | A valid ISO 4217 currency code (e.g. "USD", "EUR") |
| `currencyposition` | Choose if the currency-symbol should be before or after the amount of money: 0 = $10; 1 = 10$; |
| `priceperalbum` | Price for one session/album (e.g. 9.99) |
| `priceperphoto` | Price for one single photo (e.g. 5.99) |
| `percentperprice` | A number between 0 and 100. This is the percent of the `priceperalbum` or `priceperphoto` which goes to the `secondarymail`. The rest will go the the `primarymail`. |
| `watermark` | The watermark-id of the watermark which belongs to the user |

## Shorthand ID

The Backend uses a shorthand ID on the flyer to identify the photographer.

- The shorthand must be 2 chars long
- The code on the flyer must start with the shorthand

The shorthand ID is the ID of the photographer converted to letters. Letters are easier to read when the customer needs to enter the code on the website. The following table shows how to convert the ID into a shorthand ID:

| Number | Shorthand Equivalent |
|:-----------|:------------|
| 0 | a |
| 1 | b |
| 2 | d |
| 3 | e |
| 4 | f |
| 5 | g |
| 6 | h |
| 7 | j |
| 8 | k |
| 9 | m |

Example: The photographer with the ID `01` has the shorthand ID `ab`.