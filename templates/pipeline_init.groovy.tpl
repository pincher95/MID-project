import jenkins.model.Jenkins
import hudson.plugins.git.*;

def scm = new GitSCM("${git_url}")
scm.branches = [new BranchSpec("*/master")];
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "${project_name}")
job.definition = flowDefinition
Jenkins.get().add(job, job.name);