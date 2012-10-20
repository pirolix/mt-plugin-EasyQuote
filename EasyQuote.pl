package MT::Plugin::OMV::EasyQuote;
# $Id$

use strict;
use MT 4;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.01'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    doc_link => 'http://www.magicvox.net/archive/2010/02131254/',
    description => <<PERLHEREDOC,
Enable you to quote the HTMLs from the another entry/webpage easily.
PERLHEREDOC
});
MT->add_plugin ($plugin);

sub instance { $plugin; }



### BuildPage callback - level one
MT->add_callback ('BuildPage', 8, $plugin, sub {
    my (undef, %args) = @_;

    my $buffer = ${$args{Content}};
    while ($buffer =~ s/<!--\s*\Q$MYNAME\E\s+set\s*=\s*(["'])(\S+)\1\s*-->([\s\S]*?)<!--\s*\/\2\s*-->//is) { #"
        save_plugindata ($2, { quote => $3 });
    }
});

### BuildPage callback - level two
MT->add_callback ('BuildPage', 9, $plugin, sub {
    my (undef, %args) = @_;

    my $content = $args{Content};
    while ($$content =~ s/<!--\s*\Q$MYNAME\E\s+get\s*=\s*(["'])(\S+)\1\s*-->/load_plugindata($2)->{quote}/ise) { #"
        # do nothing
    }
});

########################################################################
use MT::PluginData;

sub save_plugindata {
    my ($key, $data_ref) = @_;
    my $pd = MT::PluginData->load ({ plugin => &instance->id, key => $key });
    if (!$pd) {
        $pd = MT::PluginData->new;
        $pd->plugin (&instance->id);
        $pd->key ($key);
    }
    $pd->data ($data_ref);
    $pd->save;
}

sub load_plugindata {
    my ($key) = @_;
    my $pd = MT::PluginData->load ({ plugin => &instance->id, key => $key })
        or return { quote => '' };
    $pd->data;
}

1;