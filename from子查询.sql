# 找出在2010年春季学期讲授一门课程的教师总数
select *
from instructor natural join teaches
where semester = 'Spring' and year = 2010;

# 结果：
/*
# ID, name, dept_name, salary, course_id, sec_id, semester, year
'95709', 'Sakurai', 'English', '118143.98', '270', '1', 'Spring', '2010'
'74420', 'Voronina', 'Physics', '121141.99', '443', '1', 'Spring', '2010'
'77346', 'Mahmoud', 'Geology', '99382.59', '493', '1', 'Spring', '2010'
'4233', 'Luo', 'English', '88791.45', '679', '1', 'Spring', '2010'
'41930', 'Tung', 'Athletics', '50482.03', '692', '1', 'Spring', '2010'
'77346', 'Mahmoud', 'Geology', '99382.59', '735', '2', 'Spring', '2010'
'Mahmoud'这个人教授了两门课
*/

select count(distinct ID)
from instructor natural join teaches
where semester = 'Spring' and year = 2010;
# 结果：5

/*
书上的解释说：不管一个老是讲授了几个课程都只被计算一次，这似乎并不是我们想要的答案，因为
我们只想要当中只教授一门课的老师。
想法：用子查询先找出每个老师教授的课程数目，然后再从子查询中找出只教授一门课的老师
*/
select sum(count_id)
from(
	select name, count(ID) as count_id
	from instructor natural join teaches
	where semester = 'Spring' and year = 2010
	group by name) as num_teaches 
where count_id = 1;
# 结果：4 和实际相符
