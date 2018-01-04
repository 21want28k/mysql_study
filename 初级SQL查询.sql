# 3.7.3
# 对于在2009年讲授的每个课程段，如果该课程段有至少2名学生选课，找出选修该课程段的所有学生的总学分的平均值
select dept_name, avg(tot_cred) as avg_tot_cred
from student natural join takes
where year = 2009
group by dept_name
having count(ID) >= 2;

# 3.8 嵌套子查询
# 3.8.1 集合成员资格
# 找出在2009年秋季和2010年春季学期同时开课的所有课程
# 方法1：交集
select course_id
from(select *
	from section
	where semester = 'Fall' and year = 2009
	union all
	select *
	from section
	where semester = 'Spring' and year = 2010) as a
group by  course_id
having count(*) > 1;
# 0.00040sec
# 交集无法使用，但是可以换种思路求交集

# 方法2：成员资格
select course_id
from section
where semester = 'Fall' and year = 2009 and course_id in(
														select course_id
														from section
														where semester = 'Spring' and year = 2010
														);
# 0.00032sec
# 找出（不同的）学生总数，他们选修了ID为10101的教师所教授的课程段
select count(distinct ID)
from takes
where (course_id, sec_id, semester, year) in (
											  select course_id, sec_id, semester, year
                                              from teaches
                                              where ID = 10101
                                              );
# 另一种写法
select count(distinct takes.ID)
from takes join teaches using(course_id, sec_id, semester, year)
where teaches.ID = 10101;

# 3.8.2集合的比较
# 找出满足下面条件的所有教师的姓名，他们的工资至少比Biology系某一个教师的工资要高
# 回顾起别名的写法
select T.name
from instructor T, instructor S
where T.salary > S.salary and S.dept_name = 'Biology';

# 当遇到至少比某一个大时 我们可以用 > some来表示(any)
select name
from instructor
where salary > some (select salary
				     from instructor
                     where dept_name = 'Biology'
                     );

# 找出满足下面条件的所有教师的姓名，他们的工资至少比Biology系所有教师的工资要高
# all
select name
from instructor
where salary > all  (select salary
				     from instructor
                     where dept_name = 'Biology'
                     );

# 3.8.3 空关系测试
# 测试一个子查询的结果中是否存在元组
# 找出在2009年秋季学期和2010年春季学期同时开课的所有课程
select T.course_id
from section T, section S
where  T.semester = 'Spring' and T.year = 2010 and 
	   S.semester = 'Fall' and S.year = 2009 and
	   T.course_id = S.course_id;
# 0.00035 sec
# 使用exists
select course_id
from section S
where S.semester = 'Fall' and S.year = 2009 and
      exists (
              select *
              from section T
              where semester = 'Spring' and year = 2010 and
              T.course_id = S.course_id
              );
# 0.00048 sec
# 虽然说用了几种方法（成员资格，交集的改写，别名，exist）测试速度，但是毕竟只是在自己的表里面使用，都用了别名，我们无法真正了解它们的速度

# 3.9.2 插入
# 单个元组的插入请求
# Computer Science系开设的名为"Database Systems:的课程CS-437,它有4个学分
insert into course
	values('CS-437', 'Database Systems', 'Comp. Sci. ', 4);

# 在查询的基础上插入元组
# 让Music 系每个修满144学分的学生成为Music 系的教师，工资为18000，事实上是不可能的，但是作为例子使用
insert into instructor
	select ID, name, dept_name, 18000
    from student
    where dept_name = 'Music' and tot_cred >= 144;

# 3.9.3 更新
# 对于工资低于平均数的教师涨5%
update instructor
set salary = salary * 1.05
where salary < (
				select avg_salary
				from
                (select avg(salary) as avg_salary
                from instructor
				)as avg_select
                );
/*
mysql里面有一个很奇怪的东西，MYSQL之You can't specify target table for update in FROM clause
就是说不能在一个表里面同时更新和子查询，不能先select出同一表中的某些值，再update这个表(在同一语句中)
解决：利用一个中间中间表让机器不觉得是来自同一个表。但是我觉得这样似乎不是最好的解决方法。有待发现
*/
# case语句：对工资超过100000美元的教师涨3%的工资，其余老师涨5%的工资

update instructor
set salary = case
			when salary < 100000 then salary * 1.05
            else salary * 1.03
		end;
# 好像非要这么写

# 当学生成功完成自己的课程（学分不是F，并且不为null的时候），算出它的总学分并且更新进学生表的tot_cred里面
update student S
set tot_cred = (
				select sum(credits)
                from takes natural join course
                where takes.ID = S.ID and
                grade <> 'F' and
                grade is not null
                );
# 一句语句很精妙不是吗？它在子查询中求和总的学分，但是却用一句takes.ID = S.ID 巧妙的和每一个学生对接起来。

# 课后小练习：
# 找出在2009年秋季拥有最多选课人数的课程段
create view takes_number as
(select course_id, sec_id, count(ID) as num_ID
from takes
where semester = 'Fall' and year = 2009
group by course_id, sec_id
);
select course_id, sec_id
from takes_number
where num_ID = (
				select max(num_ID)
                from takes_number
                );
# 不支持定义临时表，想到用视图也可以解决这个问题，先找出2009年秋季选修的课程段人数，然后再在这个里面用子查询找出人数是最多人选的那个课程
# 如果不用视图,替换一下就行了。发现：有聚集函数，又有其它属性，则其它属性必须用group by里面。

