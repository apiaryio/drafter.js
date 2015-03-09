# Drafter

[![Circle CI](https://circleci.com/gh/apiaryio/drafter.js.svg?style=svg&circle-token=f4b9c3fc34979e81d36c9d15e576e23f62e1e913)](https://circleci.com/gh/apiaryio/drafter.js)

Snow Crash parser harness.

## Introduction
Drafter takes an API blueprint on its input, parses, and then processes the AST to exposes the [Parse Result][] for further use. Drafter expands MSON data structures from the AST and generates JSON representations and JSON Schema representation of MSON structures where they are not found in the original AST.

## Installation
Node.js v0.10 is required.

```shell
$ npm install -g drafter
```

## Getting Started

### Library
```js
var Drafter = require('drafter');
var blueprint = '# GET /message\n' +
                '+ Response 200\n' +
                '\n' +
                '        Hello World!\n'

var drafter = new Drafter;
drafter.make(blueprint, function(error, result) {
    if (error) {
        console.log(error);
        return;
    }

    console.log(JSON.stringify(result, null, 2));
});
```

### CLI Tool

```shell
$ cat << 'EOF' > blueprint.apib
# GET /message
+ Response 200

        Hello World!
EOF

$ drafter blueprint.apib
```

## Resolved Named Types

The three rules for when MSON AST is expanded are:

* If a named type is a sub-type of another named type
* If a named types includes a mixin
* If a value member or property member is referencing a named type

The expanded data structures are added to the array which has the original data structures with their element name set to `resolvedDataStructure`.

## Resolved Assets

The resolved assets for a *payload body example* and *payload body schema* are added to the array in the `content` key of the **Payload Object** with their element name set to `resolvedAsset` and `role` in `attributes` set as `bodyExample` and `bodySchema` respectively.

A sample part of payload object is given below

```json
{
  "content": [
    {
      "element": "resolvedAsset",
      "attributes": {
        "role": "bodyExample"
      },
      "content": "{\"id\":\"250FF\",\"percent_off\":25,\"redeem_by\":null}"
    },
    {
      "element": "resolvedAsset",
      "attributes": {
        "role": "bodySchema"
      },
      "content": "{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"},\"percent_off\":{\"type\":\"number\"},\"redeem_by\":{\"type\":\"number\",\"description\":\"Date after which the coupon can no longer be redeemed\"}},\"$schema\":\"http://json-schema.org/draft-04/schema#\"}"
    }
  ]
}
```

## Testing

Inside the drafter repository you can execute the following to run the test suite:

```bash
$ npm install
$ npm test
```

[Boutique]: https://github.com/apiaryio/boutique.js
[Parse Result]: https://github.com/apiaryio/api-blueprint-ast/blob/master/Parse%20Result.md
