import typing as t

from .cli import cli


def main(name: t.Optional[str] = None):
    cli(
        obj={},
        help_option_names=['-h', '--help'],
        auto_envvar_prefix='APP',
        prog_name=name
    )


if __name__ == '__main__':
    main(f'python -m {__package__}')
