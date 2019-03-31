from behave import *
import os
import sys
import uuid
import compose_util
import common_util
import config_util
import shutil
import subprocess

@when(u'I start explorer')
def start_explorer_impl(context):
    curpath = os.path.realpath('.')
    composeFiles = ["%s/docker-compose/docker-compose-explorer.yaml" % (curpath)]
    if not hasattr(context, "composition_explorer"):
        context.composition_explorer = compose_util.Composition(context, composeFiles,
                                                                projectName=context.composition.projectName,
                                                                startContainers=True)
    else:
        context.composition_explorer.composeFilesYaml = composeFiles
        context.composition_explorer.up()
    context.compose_containers = context.composition.collectServiceNames()

@given(u'I start first-network')
def start_firstnetwork_impl(context):
    curpath = os.path.realpath('.')
    composeFiles = ["%s/docker-compose/first-network/docker-compose-cli.yaml" % (curpath)]
    config_util.makeProjectConfigDir(context)

    shutil.copyfile("{0}/docker-compose/first-network/crypto-config.yaml".format(curpath), "{0}/configs/{1}/crypto-config.yaml".format(curpath, context.projectName))
    shutil.copyfile("{0}/docker-compose/first-network/configtx.yaml".format(curpath), "{0}/configs/{1}/configtx.yaml".format(curpath, context.projectName))
    os.mkdir("{0}/configs/{1}/channel-artifacts".format(curpath, context.projectName))
    # config_util.buildCryptoFile(context, 2, 2, numOrderers, 2, ouEnable=ouEnabled)
    generateCryptoArtifacts(context, "mychannel")
    # config_util.generateCrypto(context, "./configs/{0}/crypto.yaml".format(context.projectName))
    # config_util.generateConfig(context, "byfn-sys-channel", "TwoOrgsChannel", "TwoOrgsOrdererGenesis")
    # shutil.copyfile("{0}/configs/{1}/byfn-sys-channel.tx".format(curpath, context.projectName), "{0}/configs/{1}/channel.tx".format(curpath, context.projectName))
    if not hasattr(context, "composition"):
        context.composition = compose_util.Composition(context, composeFiles,
                                                                projectName=context.projectName,
                                                                startContainers=True)
    else:
        context.composition.composeFilesYaml = composeFiles
        context.composition.up()
    context.compose_containers = context.composition.collectServiceNames()

    common_util.wait_until_in_log(["cli"], "Query successful on peer1.org2 on channel ")

def generateCryptoArtifacts(context, channelID):
    testConfigs = config_util.makeProjectConfigDir(context)
    updated_env = config_util.updateEnviron(context)
    try:
        command = ["../../docker-compose/first-network/byfn.sh", "generate", "-c", channelID]
        return subprocess.call(command, cwd=testConfigs, env=updated_env)
        #return subprocess.check_output(command, env=updated_env)
    except:
        print("Unable to inspect orderer config data: {0}".format(sys.exc_info()[1]))
