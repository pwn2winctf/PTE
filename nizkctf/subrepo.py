# -*- encoding: utf-8 -*-

import os
import subprocess
from .settings import Settings
from .localsettings import LocalSettings
from .repohost import RepoHost


SUBREPO_NAME = 'submissions'

thisdir = os.path.dirname(os.path.realpath(__file__))


class SubRepo(object):
    path = os.path.realpath(os.path.join(thisdir, '..', SUBREPO_NAME))

    @classmethod
    def get_path(cls, subpath=''):
        if os.path.exists(cls.path):
            return os.path.join(cls.path, subpath)
        raise EnvironmentError("The subrepository path ('%s') was not created "
                               "yet. Please call 'ctf login' to get it cloned "
                               "before performing any further actions." %
                               cls.path)

    @classmethod
    def clone(cls, fork=True):
        if fork:
            repohost = RepoHost.instance()

            forked_project, origin_url = \
                repohost.fork(Settings.submissions_project)
            LocalSettings.forked_project = forked_project

            upstream_url = repohost.get_https_url(Settings.submissions_project)
        else:
            upstream_url = origin_url = \
                repohost.get_ssh_url(Settings.submissions_project)

        cls.git(['clone', origin_url, cls.path])
        cls.git(['remote', 'add', 'upstream', upstream_url])

    @classmethod
    def pull(cls):
        cls.git(['pull', '--rebase', 'upstream', 'master'])

    @classmethod
    def sync(cls, commit_message='commit', merge_request=True):
        cls.git(['add', '-A'])
        cls.git(['commit', '-m', commit_message])
        cls.pull()
        cls.git(['push', '-u', 'origin', 'master'])

        if merge_request:
            repohost.merge_request(LocalSettings.forked_project,
                                   Settings.submissions_project,
                                   title=commit_message)

    @classmethod
    def git(cls, args, **kwargs):
        p = subprocess.Popen(['git'] + args, cwd=cls.get_path(), **kwargs)
        returncode = p.wait()
        if returncode != 0:
            raise GitError(returncode)


class GitError(Exception):
    def __init__(self, returncode, *args):
        self.returncode = returncode
        super(GitError, self).__init__(*args)