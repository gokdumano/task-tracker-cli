# Adding a new task
main add 'Buy groceries'
# Output: Task added successfully (ID: 1)

# Updating and deleting tasks
main update 1 'Buy groceries and cook dinner'
main delete 1

# Marking a task as in progress or done
main mark-in-progress 1
main mark-done 1

# Listing all tasks
main list

# Listing tasks by status
main list done
main list todo
main list in-progress