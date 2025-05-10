# jpnd

A repository of data related to the Japanese language.

## Getting Started

This project has both [Ruby] and [Python] dependencies. It is recommended that
you use [Pipenv] to install the Python dependencies.

[Ruby]: https://www.ruby-lang.org
[Python]: https://www.python.org
[Pipenv]: https://pipenv.pypa.io

Install Ruby dependencies:
```
bundle install
```

If you don't have Pipenv installed, you can install it with `pip`:
```
pip install --user pipenv
```

Install Python dependencies:
```
pipenv install
```

The data created and redistributed by this project is located separately and is
mounted via git submodules. These modules are automatically updated every week.

Initialize and update the data modules:
```
git submodule update --init
```

To update the data in each of these modules to the very latest version, build
the project with Rake:
```
bin/rake build
```

### Tokenizer

You can pipe Japanese text to the `tokenize` Rake task to split it into tokens:
```
echo -e "日本語は日本の言語です。" | bin/rake tokenize
```

Use `cat` to tokenize lines of text from a file:
```
cat text.txt | bin/rake tokenize
```

To ignore duplicate tokens use the `tokenize_unique` Rake task instead:
```
echo -e "日本語は日本の言語です。" | bin/rake tokenize_unique
```

## Data Modules

The following data modules are available:
- [chiseids](https://gitlab.com/jpnd/data-chiseids)
- [jmdict](https://gitlab.com/jpnd/data-jmdict)
- [jmnedict](https://gitlab.com/jpnd/data-jmnedict)
- [kanjidep](https://gitlab.com/jpnd/data-kanjidep)
- [kanjidic](https://gitlab.com/jpnd/data-kanjidic)
- [kanjidicdep](https://gitlab.com/jpnd/data-kanjidicdep)

All data in this project is stored in JSON lines (`.jsonl`) format. Each line in
these files is a JSON object.

Data is either stored in a single `data.jsonl` file or in sequential `.jsonl`
files in a `data` directory, ex. `data/001.jsonl`, `data/002.jsonl`,
`data/003.jsonl`, etc.

Here is an example demonstrating how to read these data files in Ruby:
```rb
require "json"

json_load = JSON.method(:load)
jsonl_load = ->(file) { file.map(&json_load) }
jsonl_read = ->(path) { File.open(path, &jsonl_load) }
jsonl_read_glob = ->(glob) { Dir.glob(glob).map(&jsonl_read).reduce(:+) }

kanjidic = "data/kanjidic/data.jsonl".then(&jsonl_read)
jmdict = "data/jmdict/data/*.jsonl".then(&jsonl_read_glob)
```

## Contributing

See: [CONTRIBUTING.md](CONTRIBUTING.md)

## License

See: [LICENSE](LICENSE)

The data distributed in this project's data modules are subject to additional
terms and conditions. Please refer to the license information in each of these
modules before using this data in your own projects.
