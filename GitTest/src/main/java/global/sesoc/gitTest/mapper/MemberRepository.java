package global.sesoc.gitTest.mapper;

import java.util.List;

import org.apache.ibatis.session.SqlSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import global.sesoc.gitTest.MemberController;
import global.sesoc.gitTest.DAO.MemberDAO;
import global.sesoc.gitTest.vo.DeptList;
import global.sesoc.gitTest.vo.JobList;
import global.sesoc.gitTest.vo.Member;

@Repository
public class MemberRepository {

	@Autowired
	SqlSession sqlsession;
	
	final static Logger logger = LoggerFactory.getLogger(MemberController.class);
	
	public int join(Member member){
		int result=0;
		
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			result = mDAO.join(member);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		return result;
	}
	
	public int update(Member member){
		   int result=0;
		      
		   MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		   try {
		      result = mDAO.update(member);
		   } catch (Exception e) {
		      e.printStackTrace();
		   }
		      
		   return result;
	}
	
	public Member selectOne(String loginNum){
		Member result = null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			result=mDAO.selectOne(loginNum);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	public List<Member> search(String loginNum){
		List<Member> result = null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			result=mDAO.search(loginNum);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	
	public List<Member> searchall(){
		List<Member> result = null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			result=mDAO.searchall();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	public List<JobList> jobList(){
		List<JobList> jobList=null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			jobList = mDAO.jobList();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return jobList;
	}
	
	public List<DeptList> deptList(){
		List<DeptList> deptList=null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			deptList = mDAO.deptList();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return deptList;
	}
	
	public int memberUpdate(Member member){
		   int result=0;
		      
		   MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		   try {
		      result = mDAO.memberUpdate(member);
		   } catch (Exception e) {
		      e.printStackTrace();
		   }
		      
		   return result;
	}
	
	public int memberDelete(String employee_num){
		   int result=0;
		      
		   MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		   try {
		      result = mDAO.memberDelete(employee_num);
		   } catch (Exception e) {
		      e.printStackTrace();
		   }
		      
		   return result;
	}
	
	public List<String> toList(){
		List<String> toList=null;
		MemberDAO mDAO = sqlsession.getMapper(MemberDAO.class);
		try {
			toList = mDAO.toList();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return toList;
	}
	
}
