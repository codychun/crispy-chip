#  (https://github.com/cvut/qtrvsim/)
#  hw03_solution_testcase1.S - HW03 Example Solution, Spring 2025
#  Created by @adingler for CSE30321,
#  based on simple-lw-sw-ia.S, (C) 2021 by Pavel Pisa
#  e-mail: pisa@cmp.felk.cvut.cz
#  homepage: http://cmp.felk.cvut.cz/~pisa
#  work: http://www.pikron.com/
#  license: public domain

#  Directives to make interesting windows visible

# pragma qtrvsim show registers
# pragma qtrvsim show memory


.globl _start
.option norelax

.text
_start:
    # ***linked list "main" goes here for each assignment***

	# Initialize the Stack Pointer (x2) near the top of 32KB RAM
    li sp, 0x7000

	#  setup code prior to loop that creates the linked list
	#  get the address of the first array element into x5
	
	#  la is pseudoinstruction to load address of label (array start, here)
	la x5, array_data
	
	#  get the number of list elements into x6
	la x6, num_elements
	lw x6, 0x0(x6)
	
	# setup linked list far past the end of the last array element
	# x8 will always keep track of the list head
	addi x8, x5, 0x200
	add x3, x8, x0	# pointer to 0x1204 for printing
	
	# pointer starts at head (for iterating over list)
	addi x9, x8, 0
	
	# loop counter for insertloop
	addi x28, x0, 0
	
	# address of first array element to insert into list
	addi x10, x5, 0
	
	# holds pointer back to most recently inserted element (null, initially)
	addi x29, x0, 0

insertloop:
	jal x1, insert
	
	# keep track of pointer to the element we just inserted
	mv x29, x9
	
	# set up next list element in non-contiguous memory
	addi x9, x9, 0x40
	
	# get the address of the next array element to add to the list
	addi x10, x10, 4
	
	# update loop counter and only loop if less than num elements
	addi x28, x28, 1
	
	blt x28, x6, insertloop
	
sorting:
	jal x1, insertionSort
	
deleting:
	# arg for deleteTheLesser: delete any list element less than this value
	li x9, 0x6789
	jal x1, deleteTheLesser
    
	ebreak


# define all functions after "main"

# ***Linked List functions go here***
# helper function to see if we need to update head
check_head:
	# nothing to update, return
	beq x10, x0, done_check_head
	
	# x10 is non-zero, it holds the new head (x10 > 0) or indicates list is empty (-1)
	# (no bgt but already know isn't equal to 0)
	bge x10, x0, not_empty
	
	# list is empty, set head pointer to NULL and return
	mv x5, x0
	jr x1

not_empty:
	mv x5, x10

done_check_head:
	jr x1


# x11 comes in as the address of the first element to swap (B)
# we can assume swap is never called on the tail

# x10 is return value: 0 if head unchanged, otherwise addr of new head
# for the comments, we'll refer to the elements involved in the swap as A B C D
#  where B and C are being swapped

swap:
	lw x20, 8(x11) # get address of C (B->next)
	beq x20, x0, done # swapping tail and/or only 1 element
	lw x21, 8(x20) # get address of D (C->next)
	sw x21, 8(x11) # B->next = D
	
	beq x21, x0, skip_tail # do not update "D" if C is tail
	sw x11, 0(x21) # D->prev = B

skip_tail:
	sw x11, 8(x20) # C->next = B
	lw x22, 0(x11) # get address of A (B->prev)
	sw x22, 0(x20) # C->prev = A
	sw x20, 0(x11) # B->prev = C
	
	beq x22, x0, skip_head # do not update "A" if B is head (B->prev is 0)
	
	sw x20, 8(x22) # A->next = C
	mv x10, x0 # indicate that head was not changed

	j done

skip_head: 
	mv x10, x20 # we updated head, return new head

done: 
	jr x1

# x11 comes in as the address of the item to delete
# we can assume there are always at least 2 elements
# (x11 cannot be head AND tail)

# x10 is return value, 0 if head unchanged, otherwise addr of new head
# for the comments, we'll refer to the elements involved in the delete as A B C
#  where B is being deleted

delete:
	lw x20, 8(x11) # get address of C (B->next)
	lw x21, 0(x11) # get address of A (B->prev)
	
	add x30, x20, x21
	
	beq x30, x0, del_single # both pointers null, deleting single-element list
	beq x20, x0, del_tail # C is null, deleting tail
	sw x21, 0(x20) # C->prev = A (OK if A is null)
	
	beq x21, x0, del_head # A is null, deleting head

del_tail:
	sw x20, 8(x21) # A->next = C (OK if A is null)
	mv x10, x0 # indicate that head was not changed
	jr x1

del_head:
	mv x10, x20 # we updated head, return new head
	jr x1

del_single:
	li x10, -1
	jr x1

insert:
	lw x18, 0x0(x10) # get data of element to add
	sw x18, 0x4(x9) # store data
	sw x29, 0x0(x9) # store previous

	# peek back at last list element (if any), and update its next pointer to this one
	beq x29, x0, insert_head

	# previous list element's next pointer points to newly-inserted element
	sw x9, 0x8(x29)

insert_head:
	# ensure the tail points ahead to null
	# note: in the simulator, all memory is initially 0, so we could
	#  safely skip this line for this assignment (but not in general)
	sw x0, 0x8(x9)
	jr x1



# sorts linked list
insertionSort:

	lw x15, 0x8(x8) # load in the head next pointer to register 15; serves as i <- (i->next)
	
	insertion_sort_loop1: 	# first while loop
		beq x15, x0, done_sorting	# if the node is the tail (head->next = 0) then terminate 
						  			# checks if only one list element,
						  			# if the list is empty ('next' would be zero in simulator),
						  			# and if i gets to the end of the list
						  
		add x16, x15, x0 	# initialize the j variable, j <- i
		
	insertion_sort_loop2: 	# nested while loop
		beq x16, x0, i_iterator 	# if the j variable points to the null address (header pointer), then this while loop is done
		
		lw x17, 0x0(x16)	# address of j -> prev (j-1)
		lw x18, 0x4(x16) 	# A[j]
		lw x19, 0x4(x17)	# A[j-1]
		
		ble x19, x18, i_iterator	# only swap if A[j-1] > A[j]
		
		# swap
		# x10 return (from swap)
		# x11 arg to swap
		add x11, x17, x0	# using x11 to pass as argument to swap() (address of the data)
		
		addi x2, x2, -4		# make space on stack	
      	sw x1, 0(x2)		# store return address x1 to stack
		jal x1, swap		# swap A[j-1] and A[j]
		lw x1, 0(x2)		# load original x1
      	addi x2, x2, 4		# restore original stack pointer
      	
		beq x10, x0, skip_sort_head_update
      	mv x8, x10			# update global head pointer
	
	skip_sort_head_update:
      	
		lw x16, 0x0(x17)	# j <- (j -> prev)
		j insertion_sort_loop2	# go back through inner while loop
	
	i_iterator:#  iterate the i variable
		lw x15, 0x8(x15) 		# pull the next of the next node; serves as i -> (i -> next), (i+1)
		j insertion_sort_loop1	# go back through outer while loop

done_sorting:
	jr x1	# done sorting


# args: 
# current head: x8
# cuttoff value: x9
deleteTheLesser:
	# iterate through the linked list
	add x13, x8, x0		# start at head, x13 used to iterate list
	
del_loop:
	lw x12, 0x4(x13)	# value of linked list element
	
	bge x12, x9, del_iter 	# if A[i] !< x9, skip the deletion
	
	# delete
	# x10 return (from delete)
	# x11 arg to delete
	add x11, x13, x0	# x11 <- address of element to delete
	
	addi x2, x2, -4		# make space on stack	
    sw x1, 0(x2)		# store return address x1 to stack
	jal x1, delete		# swap A[j-1] and A[j]
	lw x1, 0(x2)		# load original x1
    addi x2, x2, 4		# restore original stack pointer
    
    beq x10, x0, skip_deleting_head_update
    mv x8, x10			# update global head pointer
    
	skip_deleting_head_update:
	
del_iter:
	lw x13, 0x8(x13) 	# x13 <- (x13->next)
	beq x13, x0, done_deleting 	# done if next is 0x0, end of list
	j del_loop
	
done_deleting:
	jr x1	# done deleting


.data
.org 0x1000

num_elements:
	.word 0x8

array_data:
    .word  0x5468, 0x6572, 0x6520, 0x6973, 0x206E, 0x6F20, 0x7472, 0x792E


# focus on the (original) list head
# pragma qtrvsim focus memory 0x1204
