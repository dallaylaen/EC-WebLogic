# preamble.pl
$[/myProject/preamble]

my $PROJECT_NAME = '$[/myProject/projectName]';
my $PLUGIN_NAME = '@PLUGIN_NAME@';
my $PLUGIN_KEY = '@PLUGIN_KEY@';
use Data::Dumper;

$|=1;

main();

sub main {
    my $wl = EC::WebLogic->new(
        project_name => $PROJECT_NAME,
        plugin_name => $PLUGIN_NAME,
        plugin_key => $PLUGIN_KEY
    );
    my $params = $wl->get_params_as_hashref(
        'configname',
        'wlstabspath',
        'dsname'
    );

    my $cred = $wl->get_credentials($params->{configname});

    my $render_params = {
        username => $cred->{user},
        password => $cred->{password},
        weblogic_url => $cred->{weblogic_url},

        ds_name => $params->{dsname}
    };

    my $template_path = '/myProject/jython/delete_datasource.jython';
    my $template = $wl->render_template_from_property($template_path, $render_params);

    my $res = $wl->execute_jython_script(
        shell => $params->{wlstabspath},
        script_path => $ENV{COMMANDER_WORKSPACE} . '/exec.jython',
        script_content => $template,
    );

    $wl->process_response($res);
    return;
}