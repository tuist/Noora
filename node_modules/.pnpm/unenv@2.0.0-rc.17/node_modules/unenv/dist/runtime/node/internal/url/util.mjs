export function spliceOne(list, index) {
	for (; index + 1 < list.length; index++) list[index] = list[index + 1];
	list.pop();
}
