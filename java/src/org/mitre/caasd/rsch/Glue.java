package org.mitre.caasd.rsch;

import java.io.IOException;
import java.io.InputStream;

import com.jcraft.jsch.*;

public class Glue {
	private JSch sch;
	private Session sess = null;
	private Channel chan = null;
	private InputStream in = null;
	private int exitstatus = Integer.MIN_VALUE;
	public Glue(){
		sch = new JSch();
	}

	public Session getSession(String user, String password, String host, String port){


		try {
			sess= sch.getSession(user, host, Integer.parseInt(port));
		} catch (JSchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		sess.setPassword(password);

		try {
			java.util.Properties config = new java.util.Properties(); 
			config.put("StrictHostKeyChecking", "no");
			sess.setConfig(config);
			sess.connect();
		} catch (JSchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return sess;
	}

	public void sendCommand(Session sess, String cmd){

		try {
			chan = sess.openChannel("exec");
		} catch (JSchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		((ChannelExec)chan).setCommand(cmd);

		chan.setInputStream(null);

		((ChannelExec)chan).setErrStream(System.err);



		try {
			in =chan.getInputStream();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		try {
			chan.connect();
		} catch (JSchException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 

	}

	public String printout(){
		String retString = "";
		try {
			StringBuilder sb = new StringBuilder();
			byte[] tmp=new byte[1024];
			while(true){
				while(in.available()>0){
					int i=in.read(tmp, 0, 1024);
					if(i<0)break;
					//System.out.print(new String(tmp, 0, i));
					sb.append(new String(tmp, 0, i));
				}
				if(chan.isClosed()){
					if(in.available()>0) continue;
					exitstatus = chan.getExitStatus();
					break;
				}
				try{Thread.sleep(100);}catch(Exception ee){}
			} 
			retString = sb.toString();
		} catch(IOException eieio){
			eieio.printStackTrace();
		}
		
		return(retString);
	}

	public void goodbye(){
		System.out.println("exit-status: " + exitstatus);
		chan.disconnect();
		sess.disconnect(); 
	}
	public static void main(String[] args) {
//			Glue g = new Glue();
//			Session s = g.getSession("swenchel", "","comp64-1.mitre.org", "22");
//			g.sendCommand(s, "echo c.foo");
//			System.out.println(g.printout());
//			g.sendCommand(s, "ls *.foo");
//			g.printout();
//			g.goodbye();
//		System.out.println("");

	}
}
