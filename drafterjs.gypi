{
    "includes": [
        "ext/drafter/common.gypi"
    ],

    "targets": [
        # drafter.js c/c++ lib
        {
            "target_name": "libdrafterjs",
            'type': 'static_library',
            "sources": [
                "src/cparse.h",
                "src/cparse.cc",
            ],
            "dependencies": [
                'ext/drafter/drafter.gyp:libdrafter',
            ],
        },
    ],
}
