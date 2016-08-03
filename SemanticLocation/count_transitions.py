def count_transitions(x, state1, state2):

	cnt = 0

	for i in range(x.size-1):

		if x[i]==state1 and x[i+1]==state2:
			cnt += 1

	return cnt