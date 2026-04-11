# pyda

A python package for LTPDA-like data analysis.


## Development setup

### Poetry
Use [Poetry](https://python-poetry.org/) to manage the development packages.

```bash
poetry install
```

To add a new dependency use
```bash
poetry add <package name>
```

### Tests
Please write unittests if you add new features.
The structure for the test should represent the structure of the package itself.
Each subpackage should have its own folder prefixed with `test_` and should contain subfolders with the same structure.
Every `.py` file (module) should be represented by one folder containing test files that test specific functions of that file.
For example:
- `test`
    - `test_subpackage1`
        - `test_module1`
            - `test_function1_of_module1.py`
            - `test_function2_of_module1.py`
        - `test_module2`
            - `test_function1_of_module2.py`
            - `test_function2_of_module2.py`
    - `test_subpackage2`

For very simple classes or modules, the whole module can be tested in one `test_module.py` file but may still be contained inside a folder with the same name.
All tests located in `src/test/*` are automatically tested when pushing to Gitlab.

To run them manually use:
```bash
make test
```

### Code Formatter

We use [`pre-commit`](https://pre-commit.com/#python) for automatic code formatting before committing.
It is automatically installed with the development packages.
The command to enable the hooks is:
```bash
poetry run pre-commit install
```

### Release a new version

#### 1. Use poetry to change the version number
```bash
poetry version patch  # small fixes
poetry version minor  # small features
poetry version major  # breaking changes
```

#### 2. Merge it to Main

From the `main` branch the deployment process will finish it automatically.
