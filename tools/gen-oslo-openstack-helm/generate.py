#!/usr/bin/env python

# Copyright 2012 SINA Corporation
# Copyright 2014 Cisco Systems, Inc.
# All Rights Reserved.
# Copyright 2014 Red Hat, Inc.
# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import logging
import operator
import sys
import textwrap
import re
import traceback

import pkg_resources
import six

from oslo_config._i18n import _
from oslo_config import cfg

from oslo_config.generator import _get_groups, _list_opts, _format_defaults, \
        _TYPE_NAMES

import stevedore.named  # noqa

LOG = logging.getLogger(__name__)
UPPER_CASE_GROUP_NAMES = ['DEFAULT']


def _format_type_name(opt_type):
    """Format the type name to use in describing an option"""
    try:
        return opt_type.type_name
    except AttributeError:  # nosec
        pass

    try:
        return _TYPE_NAMES[opt_type]
    except KeyError:  # nosec
        pass

    return 'unknown value'


_generator_opts = [
    cfg.StrOpt(
        'output-file',
        help='Path of the file to write to. Defaults to stdout.'),
    cfg.IntOpt(
        'wrap-width',
        default=70,
        help='The maximum length of help lines.'),
    cfg.MultiStrOpt(
        'namespace',
        required=True,
        help='Option namespace under "oslo.config.opts" in which to query '
        'for options.'),
    cfg.StrOpt(
        'helm_namespace',
        required=True,
        help="Helm Namespace, e.g. 'keystone'"),
    cfg.StrOpt(
        'helm_chart',
        required=True,
        help="Helm Chart Name, e.g. 'keystone'"),
    cfg.BoolOpt(
        'minimal',
        default=False,
        help='Generate a minimal required configuration.'),
    cfg.BoolOpt(
        'summarize',
        default=False,
        help='Only output summaries of help text to config files. Retain '
        'longer help text for Sphinx documents.'),
]


def register_cli_opts(conf):
    """Register the formatter's CLI options with a ConfigOpts instance.

    Note, this must be done before the ConfigOpts instance is called to parse
    the configuration.

    :param conf: a ConfigOpts instance
    :raises: DuplicateOptError, ArgsAlreadyParsedError
    """
    conf.register_cli_opts(_generator_opts)


def _output_opts_null(f, group, group_data, minimal=False, summarize=False):
    pass
    f.format_group(group_data['object'] or group)
    for (namespace, opts) in sorted(group_data['namespaces'],
                                    key=operator.itemgetter(0)):
        for opt in sorted(opts, key=operator.attrgetter('advanced')):
            try:
                if minimal and not opt.required:
                    pass
                else:
                    f.format(opt, group, namespace, minimal, summarize)
            except Exception as err:
                pass


def _output_opts(f, group, group_data, minimal=False, summarize=False):
    f.format_group(group_data['object'] or group)
    for (namespace, opts) in sorted(group_data['namespaces'],
                                    key=operator.itemgetter(0)):
        f.write('\n#\n# From %s\n#\n' % namespace)
        for opt in sorted(opts, key=operator.attrgetter('advanced')):
            try:
                if minimal and not opt.required:
                    pass
                else:
                    f.write('\n')
                    f.format(opt, group, namespace, minimal, summarize)
            except Exception as err:
                f.write('# Warning: Failed to format sample for %s\n' %
                        (opt.dest,))
                f.write('# %s\n' % (traceback.format_exc(),))


class _ValuesSkeletonFormatter(object):

    """Format configuration option descriptions to a file."""

    def __init__(self, output_file=None, wrap_width=70):
        """Construct an OptFormatter object.

        :param output_file: a writeable file object
        :param wrap_width: The maximum length of help lines, 0 to not wrap
        """
        self.output_file = output_file or sys.stdout
        self.wrap_width = wrap_width
        self.done = []

    def _format_help(self, help_text):
        pass

    def _get_choice_text(self, choice):
        pass

    def format_group(self, group_or_groupname):
        pass

    def format(self, opt, group_name, namespace, minimal=False,
               summarize=False):
        """Format a description of an option to the output file.

        :param opt: a cfg.Opt instance
        :param group_name: name of the group to which the opt is assigned
        :param minimal: enable option by default, marking it as required
        :param summarize: output a summarized description of the opt
        :returns: a formatted opt description string
        """

        if hasattr(opt.type, 'format_defaults'):
            defaults = opt.type.format_defaults(opt.default,
                                                opt.sample_default)
        else:
            LOG.debug(
                "The type for option %(name)s which is %(type)s is not a "
                "subclass of types.ConfigType and doesn't provide a "
                "'format_defaults' method. A default formatter is not "
                "available so the best-effort formatter will be used.",
                {'type': opt.type, 'name': opt.name})
            defaults = _format_defaults(opt)
        lines = []

        for default_str in defaults:

            if len(group_name.split('.')) > 1:

                line = '{{- if not .%s -}}\
{{- set . "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower().split('.')[0],
                    group_name.lower().split('.')[0])

                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

                line = '{{- if not .%s.%s -}}\
{{- set .%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower().split('.')[0],
                    group_name.lower().split('.')[1],
                    group_name.lower().split('.')[0],
                    group_name.lower().split('.')[1])

                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            else:
                line = '{{- if not .%s -}}\
{{- set . "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    group_name.lower())
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(namespace.split('.')) == 1:
                line = '{{- if not .%s.%s -}}\
{{- set .%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace,
                    group_name.lower(),
                    namespace)
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(namespace.split('.')) > 1:
                line = '{{- if not .%s.%s -}}\
{{- set .%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace.split('.')[0],
                    group_name.lower(),
                    namespace.split('.')[0])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

                line = '{{- if not .%s.%s.%s -}}\
{{- set .%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1],
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(namespace.split('.')) > 2:
                line = '{{- if not .%s.%s.%s.%s -}}\
{{- set .%s.%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1],
                    namespace.split('.')[2],
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1],
                    namespace.split('.')[2])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(namespace.split('.')) > 3:
                line = '{{- if not .%s.%s.%s.%s.%s -}}\
{{- set .%s.%s.%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1],
                    namespace.split('.')[2],
                    namespace.split('.')[3],
                    group_name.lower(),
                    namespace.split('.')[0],
                    namespace.split('.')[1],
                    namespace.split('.')[2],
                    namespace.split('.')[3])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(opt.dest.split('.')) > 1:
                line = '{{- if not .%s.%s.%s -}}\
{{- set .%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0],
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(opt.dest.split('.')) > 2:
                line = '{{- if not .%s.%s.%s.%s -}}\
{{- set .%s.%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0],
                    opt.dest.split('.')[1],
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0],
                    opt.dest.split('.')[1])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

            if len(opt.dest.split('.')) > 3:
                line = '{{- if not .%s.%s.%s.%s.%s -}}\
{{- set .%s.%s.%s.%s "%s" dict -}}\
{{- end -}}\n' % (
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0],
                    opt.dest.split('.')[1],
                    opt.dest.split('.')[2],
                    group_name.lower(),
                    namespace,
                    opt.dest.split('.')[0],
                    opt.dest.split('.')[1],
                    opt.dest.split('.')[2])
                if line not in self.done:
                    self.done.append(line)
                    lines.append(line)

        if lines:
            self.writelines(lines)

    def write(self, s):
        """Write an arbitrary string to the output file.

        :param s: an arbitrary string
        """
        self.output_file.write(s)

    def writelines(self, l):
        """Write an arbitrary sequence of strings to the output file.

        :param l: a list of arbitrary strings
        """
        self.output_file.writelines(l)


class _HelmOptFormatter(object):

    """Format configuration option descriptions to a file."""

    def __init__(self, output_file=None, wrap_width=70):
        """Construct an OptFormatter object.

        :param output_file: a writeable file object
        :param wrap_width: The maximum length of help lines, 0 to not wrap
        """
        self.output_file = output_file or sys.stdout
        self.wrap_width = wrap_width

    def _format_help(self, help_text):
        """Format the help for a group or option to the output file.

        :param help_text: The text of the help string
        """
        if self.wrap_width is not None and self.wrap_width > 0:
            wrapped = ""
            for line in help_text.splitlines():
                text = "\n".join(textwrap.wrap(line, self.wrap_width,
                                               initial_indent='# ',
                                               subsequent_indent='# ',
                                               break_long_words=False,
                                               replace_whitespace=False))
                wrapped += "#" if text == "" else text
                wrapped += "\n"
            lines = [wrapped]
        else:
            lines = ['# ' + help_text + '\n']
        return lines

    def _get_choice_text(self, choice):
        if choice is None:
            return '<None>'
        elif choice == '':
            return "''"
        return six.text_type(choice)

    def format_group(self, group_or_groupname):
        """Format the description of a group header to the output file

        :param group_or_groupname: a cfg.OptGroup instance or a name of group
        :returns: a formatted group description string
        """
        if isinstance(group_or_groupname, cfg.OptGroup):
            group = group_or_groupname
            lines = ['[%s]\n' % group.name]
            if group.help:
                lines += self._format_help(group.help)
        else:
            groupname = group_or_groupname
            lines = ['[%s]\n' % groupname]
        self.writelines(lines)

    def format(self, opt, group_name, namespace, minimal=False,
               summarize=False):
        """Format a description of an option to the output file.

        :param opt: a cfg.Opt instance
        :param group_name: name of the group to which the opt is assigned
        :param minimal: enable option by default, marking it as required
        :param summarize: output a summarized description of the opt
        :returns: a formatted opt description string
        """
        if not opt.help:
            LOG.warning(_('"%s" is missing a help string'), opt.dest)

        opt_type = _format_type_name(opt.type)
        opt_prefix = ''
        if (opt.deprecated_for_removal and
                not opt.help.startswith('DEPRECATED')):
            opt_prefix = 'DEPRECATED: '

        if opt.help:
            # an empty line signifies a new paragraph. We only want the
            # summary line
            if summarize:
                _split = opt.help.split('\n\n')
                opt_help = _split[0].rstrip(':').rstrip('.')
                if len(_split) > 1:
                    opt_help += '. For more information, refer to the '
                    opt_help += 'documentation.'
            else:
                opt_help = opt.help

            help_text = u'%s%s (%s)' % (opt_prefix,
                                        opt_help,
                                        opt_type)
        else:
            help_text = u'(%s)' % opt_type
        lines = self._format_help(help_text)

        if getattr(opt.type, 'min', None) is not None:
            lines.append('# Minimum value: %d\n' % opt.type.min)

        if getattr(opt.type, 'max', None) is not None:
            lines.append('# Maximum value: %d\n' % opt.type.max)

        if getattr(opt.type, 'choices', None):
            choices_text = ', '.join([self._get_choice_text(choice)
                                      for choice in opt.type.choices])
            lines.append('# Allowed values: %s\n' % choices_text)

        try:
            if opt.mutable:
                lines.append(
                    '# Note: This option can be changed without restarting.\n'
                )
        except AttributeError as err:
            # NOTE(dhellmann): keystoneauth defines its own Opt class,
            # and neutron (at least) returns instances of those
            # classes instead of oslo_config Opt instances. The new
            # mutable attribute is the first property where the API
            # isn't supported in the external class, so we can use
            # this failure to emit a warning. See
            # https://bugs.launchpad.net/keystoneauth/+bug/1548433 for
            # more details.
            import warnings
            if not isinstance(opt, cfg.Opt):
                warnings.warn(
                    'Incompatible option class for %s (%r): %s' %
                    (opt.dest, opt.__class__, err),
                )
            else:
                warnings.warn('Failed to fully format sample for %s: %s' %
                              (opt.dest, err))

        for d in opt.deprecated_opts:
            lines.append('# Deprecated group/name - [%s]/%s\n' %
                         (d.group or group_name, d.name or opt.dest))

        if opt.deprecated_for_removal:
            if opt.deprecated_since:
                lines.append(
                    '# This option is deprecated for removal since %s.\n' % (
                        opt.deprecated_since))
            else:
                lines.append(
                    '# This option is deprecated for removal.\n')
            lines.append(
                '# Its value may be silently ignored in the future.\n')
            if opt.deprecated_reason:
                lines.extend(
                    self._format_help('Reason: ' + opt.deprecated_reason))

        if opt.advanced:
            lines.append(
                '# Advanced Option: intended for advanced users and not used\n'
                '# by the majority of users, and might have a significant\n'
                '# effect on stability and/or performance.\n'
            )

        if hasattr(opt.type, 'format_defaults'):
            defaults = opt.type.format_defaults(opt.default,
                                                opt.sample_default)
        else:
            LOG.debug(
                "The type for option %(name)s which is %(type)s is not a "
                "subclass of types.ConfigType and doesn't provide a "
                "'format_defaults' method. A default formatter is not "
                "available so the best-effort formatter will be used.",
                {'type': opt.type, 'name': opt.name})
            defaults = _format_defaults(opt)
        for default_str in defaults:
            if type(opt) in [cfg.MultiOpt, cfg.MultiStrOpt]:
                lines.append('# from .%s.%s.%s (multiopt)\n' % (
                                    group_name.lower(),
                                    namespace, opt.dest))
                lines.append('{{ if not .%s.%s.%s }}#%s = '
                             '{{ .%s.%s.%s | default "%s" }}{{ else }}'
                             '{{ range .%s.%s.%s }}%s = {{ . }}\n{{ end }}'
                             '{{ end }}\n' % (
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    opt.dest,
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    default_str.replace('"', r'\"'),
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    opt.dest))

            else:
                lines.append('# from .%s.%s.%s\n' % (
                                    group_name.lower(),
                                    namespace,
                                    opt.dest))
                if minimal:
                    lines.append('%s = {{ .%s.%s.%s | default "%s" }}\n' % (
                                    opt.dest,
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    default_str.replace('"', r'\"')))
                else:
                    lines.append('{{ if not .%s.%s.%s }}#{{ end }}%s = '
                                 '{{ .%s.%s.%s | default "%s" }}\n' % (
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    opt.dest,
                                    group_name.lower(),
                                    namespace,
                                    opt.dest,
                                    default_str.replace('"', r'\"')))

        self.writelines(lines)

    def write(self, s):
        """Write an arbitrary string to the output file.

        :param s: an arbitrary string
        """
        self.output_file.write(s)

    def writelines(self, l):
        """Write an arbitrary sequence of strings to the output file.

        :param l: a list of arbitrary strings
        """
        self.output_file.writelines(l)


def generate(conf):
    """Generate a sample config file.

    List all of the options available via the namespaces specified in the given
    configuration and write a description of them to the specified output file.

    :param conf: a ConfigOpts instance containing the generator's configuration
    """
    conf.register_opts(_generator_opts)

    output_file = (open(conf.output_file, 'w')
                   if conf.output_file else sys.stdout)

    output_file.write('''# Copyright 2017 The Openstack-Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{ include "%s.conf.%s_values_skeleton" .Values.conf.%s | trunc 0 }}
{{ include "%s.conf.%s" .Values.conf.%s }}
\n''' % (conf.helm_chart,
         conf.helm_namespace,
         conf.helm_namespace,
         conf.helm_chart,
         conf.helm_namespace,
         conf.helm_namespace))

    output_file.write('''
{{- define "%s.conf.%s_values_skeleton" -}}
\n''' % (conf.helm_chart, conf.helm_namespace))

    # values skeleton
    formatter = _ValuesSkeletonFormatter(output_file=output_file,
                                         wrap_width=conf.wrap_width)

    groups = _get_groups(_list_opts(conf.namespace))

    # Output the "DEFAULT" section as the very first section
    _output_opts_null(formatter, 'DEFAULT', groups.pop('DEFAULT'),
                      conf.minimal, conf.summarize)

    # output all other config sections with groups in alphabetical order
    for group, group_data in sorted(groups.items()):
        _output_opts_null(formatter, group, group_data, conf.minimal,
                          conf.summarize)

    output_file.write('''
{{- end -}}
\n''')

    output_file.write('''
{{- define "%s.conf.%s" -}}
\n''' % (conf.helm_chart, conf.helm_namespace))

    # helm options
    formatter = _HelmOptFormatter(output_file=output_file,
                                  wrap_width=conf.wrap_width)

    groups = _get_groups(_list_opts(conf.namespace))

    # Output the "DEFAULT" section as the very first section
    _output_opts(formatter, 'DEFAULT', groups.pop('DEFAULT'), conf.minimal,
                 conf.summarize)

    # output all other config sections with groups in alphabetical order
    for group, group_data in sorted(groups.items()):
        formatter.write('\n\n')
        _output_opts(formatter, group, group_data, conf.minimal,
                     conf.summarize)

    output_file.write('''
{{- end -}}
\n''')


# generate helm defaults
def main(args=None):
    """The main function of oslo-config-generator."""
    version = pkg_resources.get_distribution('oslo.config').version
    logging.basicConfig(level=logging.WARN)
    conf = cfg.ConfigOpts()
    register_cli_opts(conf)
    conf(args, version=version)
    generate(conf)


if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(main())
