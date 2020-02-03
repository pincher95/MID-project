import com.cloudbees.jenkins.plugins.sshslaves.verification.*
import com.cloudbees.jenkins.plugins.sshslaves.SSHConnectionDetails
import hudson.model.*
import jenkins.model.*
import hudson.slaves.*
import hudson.slaves.EnvironmentVariablesNodeProperty.Entry

// Pick one of the strategies from the comments below this line
ServerKeyVerificationStrategy serverKeyVerificationStrategy = new BlindTrustConnectionVerificationStrategy() // "Non-verifying Verification Strategy"
// new TrustInitialConnectionVerificationStrategy(false)
// = new TrustInitialConnectionVerificationStrategy(false /* "Require manual verification of initial connection" */) // "Manually trusted key verification Strategy"
// = new ManuallyConnectionVerificationStrategy("<your-key-here>") // "Manually provided key verification Strategy"
// = new KnownHostsConnectionVerificationStrategy() // "~/.ssh/known_hosts file Verification Strategy"

// Define a "Launch method": "Launch slave agents via SSH"
ComputerLauncher launcher = new com.cloudbees.jenkins.plugins.sshslaves.SSHLauncher(
        "${jenkins_agent_ip}", // Host
        new SSHConnectionDetails(
                "jenkins_SSH_Key",//"credentialsId", // Credentials ID
                22, // port
                (String)null, // JavaPath
                (String)null, // JVM Options
                (String)null, // Prefix Start Slave Command
                (String)null, // Suffix Start Slave Command
                (boolean)false, // Log environment on initial connect
                (ServerKeyVerificationStrategy) serverKeyVerificationStrategy // Host Key Verification Strategy
        )
)

// Define a "Permanent Agent"
Slave agent = new DumbSlave(
        "agent-node",
        "/home/ec2-user",
        launcher)
agent.nodeDescription = "Agent node description"
agent.numExecutors = 1
agent.labelString = "agent-node-label"
agent.mode = Node.Mode.NORMAL
agent.retentionStrategy = new RetentionStrategy.Always()

List<Entry> env = new ArrayList<Entry>();
env.add(new Entry("key1","value1"))
env.add(new Entry("key2","value2"))
EnvironmentVariablesNodeProperty envPro = new EnvironmentVariablesNodeProperty(env);

agent.getNodeProperties().add(envPro)

// Create a "Permanent Agent"
Jenkins.instance.addNode(agent)

return "Node has been created successfully."


