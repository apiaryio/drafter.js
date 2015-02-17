# Drafter

[![Circle CI](https://circleci.com/gh/apiaryio/drafter.js.svg?style=svg&circle-token=f4b9c3fc34979e81d36c9d15e576e23f62e1e913)](https://circleci.com/gh/apiaryio/drafter.js)

Snow Crash parser harness.

## Introduction
Drafter takes an API blueprint on its input, parses, processes the AST and exposes the [Parse Result][] for further use.

Want to know more? See the [Drafter Story card][].

## Installation
Node.js v0.10 is required.

```shell
$ npm install -g git+ssh://git@github.com:apiaryio/drafter.js.git
```

Because one of Drafter's dependencies, [Boutique][], lives in a private GitHub repository and has no public _npm_ package, it's referenced by its Git URL in `package.json`. Because of this, you may experience some issues while installing or testing.

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

Named Types (and anonymous named types) are expanded in-place in the AST. The three rules for when MSON AST is expanded are:

* If a named type is a sub-type of another named type
* If a named types includes a mixin
* If a value member or property member is referencing a named type

## Resolved Assets

The resolved assets for a *payload body example* and *payload body schema* are added to the array in the `content` key of the **Payload Object** with their element name set to `resolvedAsset` and `role` in `attributes` set as `bodyExample` and `bodySchema` respectively.

```json
{
  // This is the payload object
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

## Test
In order to run CI tests you need to have access to both Drafter and Boutique repositories and you need to give CircleCI some extended permissions over all your repositories to enable testing on their machines.

See _Project Settings > Checkout SSH keys > Add User GitHub Key_ in CircleCI settings.

[Drafter Story card]: https://trello.com/c/lS76AEU3/21-drafter
[Boutique]: https://github.com/apiaryio/boutique
[Parse Result]: https://github.com/apiaryio/api-blueprint-ast/blob/master/Parse%20Result.md
