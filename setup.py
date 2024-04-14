from setuptools import setup

setup(
    name='redis_s3_exporter',
    version='0.1',
    scripts=['exporter.py'],
    install_requires=[
        'boto3',
        'redis'
    ]
)
