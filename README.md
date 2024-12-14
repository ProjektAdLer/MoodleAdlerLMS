# AdLer LMS - Moodle for our project

This project extends the bitnami/moodle image for use with AdLer.

## Windows Users

This project works only under Linux.
Git on Windows (also WSL) breaks the line endings which is why it cannot be used there.
Also, editing on Windows can cause the project to stop working on Linux as well.
To use this project on Windows you have to disable the option core.autocrlf
(why the hell does this option exist and why is it enabled by default on Windows...).
To do this run the following command before the git clone `git config --global core.autocrlf false`.

**ATTENTION**: This affects all git repositories on this PC.

If you want to run this project with Windows without disabling autocrlf you can use an Docker-twostage approach.
I will not support this, but this is an approach you could use to implement it by yourself:

```
RUN apk add dos2unix
RUN cat setup.sh | dos2unix > setup.sh.tmp
RUN mv setup.sh.tmp setup.sh
RUN chmod +x setup.sh
```

## Environment variables

All variables from the bitnami/moodle image are supported. Additionally, the following environment variables can be set:

### PHP environment variables

| Variable               | required | Description                                                                                                  |
|------------------------|----------|--------------------------------------------------------------------------------------------------------------|
| `PHP_OUTPUT_BUFFERING` | no       | Controls the output buffering behavior of PHP. Set it to adjust the buffering setting in the `php.ini` file. |

### Moodle user creation variables

| Variable                             | required                     | Description                   |
|--------------------------------------|------------------------------|-------------------------------|
| `DECLARATIVE_SETUP_MANAGER_PASSWORD` | if role `test_users` is used | Password for the manager user |
| `DECLARATIVE_SETUP_STUDENT_PASSWORD` | if role `test_users` is used | Password for the student user |

### Other environment variables

| Variable               | required | Description                                                                                                                           |
|------------------------|----------|---------------------------------------------------------------------------------------------------------------------------------------|
| `ADLER_PLAYBOOK_ROLES` | no       | roles to be passed to playbook, see [AdLer Playbook](https://github.com/ProjektAdLer/MoodlePlugin-playbook_adler) for a list of roles |

#### Examples

## Updating moodle

> [!IMPORTANT]  
> The moodle release is NOT updated automatically in any way! \
> Incrementing MOODLE_VERSION build arg will not result in an update of moodle.

Moodle updates have to be done manually (Plugins are not affected by this issue).
Follow the [Bitnami Moodle Upgrade Guide](https://docs.bitnami.com/aws/apps/moodle/administration/upgrade/).
Sadly it is not easy to automate that process as moodle itself does not provide a way to automatically update moodle.

It might be within the realm of possibility to provide AdLer images with moodle and Plugins preinstalled,
but with this approach all additional plugins would be deleted after every update (potentially breaking moodle).

A possible approach to mitigate this issue might be placing an overlay volume on top of the whole moodle directory of
this
moodle image. But it is unknown whether this would work and what potential issues might arise from this.

## Docker Build Arguments

When building the Docker image for this project, you can customize the following arguments:

- `MOODLE_VERSION`: Specifies the version of Moodle to be used in the image. The default value is `latest`.

These arguments allow you to control the versions of Moodle and the plugin that are used during the image build process.
You can adjust these values according to your specific
requirements and preferences.

## Install additional languages

1) Install the required system locale by modifying the Dockerfile. You can see which one you need by manually enabling
   the desired
   language pack in moodle and checking the displayed error message.
2) Install the moodle language pack either via web interface or by modifying the playbook.

## Troubleshooting

**Moodle setup fails with "The configuration file config.php alreaady exists. ...":** \
This typically indicates the setup script already failed during a previous run. Have a look on the logs of the first
execution. 