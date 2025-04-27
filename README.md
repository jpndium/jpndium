# jd

Japanese Data (JD), a repository of data related to the Japanese language.

## Getting Started

Install Ruby dependencies:
```
bundle install
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

To list the available Rake tasks:
```
bin/rake -T
```

## Data Modules

The following data modules are available:
- [chiseids](https://gitlab.com/mrpudn/jd-chiseids)
- [jmdict](https://gitlab.com/mrpudn/jd-jmdict)
- [jmdictpri](https://gitlab.com/mrpudn/jd-jmdictpri)
- [jmnedict](https://gitlab.com/mrpudn/jd-jmnedict)
- [jmnedictpri](https://gitlab.com/mrpudn/jd-jmnedictpri)
- [kanjidep](https://gitlab.com/mrpudn/jd-kanjidep)
- [kanjidic](https://gitlab.com/mrpudn/jd-kanjidic)
- [kanjidicdep](https://gitlab.com/mrpudn/jd-kanjidicdep)

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

## License

See: [LICENSE](LICENSE)

The data distributed in this project's data modules are subject to additional
terms and conditions. Please refer to the license information in each of these
modules before using this data in your own projects.
