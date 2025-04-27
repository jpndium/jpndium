# Contributing

Thank you for your interest in contributing to this project. The instructions in
this document should help you make your contribution.

## Development

Install development dependencies:
```
bundle install
pipenv install --dev
```

Lint Ruby files with [Rubocop]:
```
bin/rubocop
```

[Rubocop]: https://rubocop.org

Run the tests with [RSpec]:
```
bin/rspec
```

[RSpec]: https://rspec.info

Update the data in the data modules with [Rake]:
```
bin/rake build
```

[Rake]: https://ruby.github.io/rake/

For a list of the available Rake tasks run:
```
bin/rake -T
```

## Conventions

Three Rake tasks are defined for each data module: `build`, `clean`, and
`update`. The `build` task should just call `clean` and `update` in order. Tasks
are automatically loaded by the `Rakefile` from any `.rake` file located in the
`lib` directory.

Many of the data modules contain data from external sources that has be
downloaded and reformatted. This data is downloaded to the `tmp` directory by
`download` Rake tasks.

Each data module has a corresponding reader. Readers read data from the `tmp`
directory or from other data modules. The output from a reader is stored in the
respective data module in either a single `data.jsonl` file or in several
sequential `.jsonl` files in a `data` directory.

## Automatic Updates

An automated process updates the data in this project every Sunday at 12:00 UTC.

The process does the following:
1. Executes the default Rake task
2. For each data module ...
    1. Commits the updated data
    2. Tags the HEAD commit with the date (`YYYY-MM-DD`)
    3. Pushes the new commit and tag
3. Commits the updated submodule refs
4. Tags the HEAD commit with the date (`data-YYYY-MM-DD`)
5. Pushes the new commit and tag
