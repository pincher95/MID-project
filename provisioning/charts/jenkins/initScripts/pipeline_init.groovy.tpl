import jenkins.model.Jenkins
import hudson.plugins.git.*;
def scm = new GitSCM("https://github.com/pincher95/crud-application-using-flask-and-mysql.git")
scm.branches = [new BranchSpec("*/master")];
def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")
def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "OpsSchool-Project")
job.definition = flowDefinition
Jenkins.get().add(job, job.name);