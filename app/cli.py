import logging
import typing as t
from pathlib import Path

import click

from app.stub import run_stub

logger = logging.getLogger(__package__)


def validator_path(ctx: click.Context, param: click.Parameter, value: str) -> t.Optional[Path]:
    try:
        return Path(value).absolute() if value else None
    except Exception:
        raise click.BadParameter(f'{param} is not valid')


@click.group()
@click.option('--log-level', '-l',
              default='DEBUG', help='Set log level.',
              type=click.Choice(['CRITICAL', 'ERROR', 'WARNING',
                                 'INFO', 'DEBUG', 'NOTSET']))
@click.pass_context
def cli(ctx: click.Context, log_level: str):
    logging.basicConfig(
        format='%(asctime)s [%(levelname)s:%(name)s] %(message)s',
        datefmt='%y-%m-%d %H:%M:%S',
        level=log_level
    )


@cli.command()
@click.pass_context
def run(ctx: click.Context):
    try:
        run_stub()
    except Exception as e:
        logger.error('App failed to start: %s', e)
        ctx.exit(1)
    else:
        logger.info('App started successfully.')
