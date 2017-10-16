#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Code Names Card
@author: ivory
"""

import argparse
import random
import numpy as np


def retrieve_args():

	parser = argparse.ArgumentParser(description='Create a spy map card like the one used for the Code Names board game.')
	# hieght
	parser.add_argument("-H", "--hieght", metavar='H', type=int, default=None, nargs='?',
	                    help='number of rows in the grid (default 5 or equal to width)')
	# width
	parser.add_argument('-W', "--width", metavar='W', type=int, default=None, nargs='?',
	                    help='number of columns in the grid (default 5 or equal to hieght)')
	# assassin
	parser.add_argument('-a', "--assassin", metavar='a', type=int, default=1, nargs='?',
	                    help='number of assisins')
	# inocent bystanders
	parser.add_argument('-i', "--incents", metavar='i', type=int, default=None, nargs='?',
	                    help='number of innocent by-stander squares', dest="ib")
	# blue team
	parser.add_argument('-b', "--blue", metavar='b', type=int, default=None, nargs='?',
	                    help='number of blue team squares')
	# red team
	parser.add_argument('-r', "--red", metavar='r', type=int, default=None, nargs='?',
	                    help='number of red team squares')
	# output file name
	parser.add_argument('-o', "--outfile", metavar='i', type=str, nargs='?',
	                    help='file name to save image (default: SpyMap.png)', 
	                    default="SpyMap.png",)
	# random seed
	parser.add_argument('-s', "--set-seed", metavar='s', type=int, default=None, nargs='?',
	                    help='set random seed to regenerate an identical card', dest="ss")

	args = parser.parse_args()

	return args


def process_grid_size(args):
	# if both hieght and width are null, set both to 5.
	# if only one is NULL, set it to match the other.
	if args.hieght is None and args.width is None:
		args.hieght = 5
		args.width = 5
	elif args.hieght is None:
		args.hieght = args.width
	elif args.width is None:
		args.width = args.hieght

	ts = args.width * args.hieght
	return args, ts



def process_square_types(args, ts):
	# Notice that the order of handling cases matters
	# first - if both blue and red are specified
	# second - if neighter are specified 
	#     (if they were specified, this is correctly skipped)
	# last - if either one is null 
	#     (which must be exactly one, since both values would have 
	#     been set by now if both or neither had been specified.)
	#     so we can assume that the other is NOT None
	first = ""

	# if neither -b nor -r is None (both are specified)
	if args.blue is not None and args.red is not None:
		# calculate open squares, total - assassin - red - blue
		openSq = ts - args.assassin - args.blue - args.red
		if openSq < 0:
			sys.exit("Not enough squares in the grid.\n")
		if args.ib is not None and args.ib != openSq:
			sys.exit("This doesn't add up. Check the number of squares you need.")
		if args.ib is None:
			args.ib = openSq
		if args.blue >= args.red:
			first = "blue"
		else: 
			first = "red"

	# if both -b and -r are None
	if args.blue is None and args.red is None:
		#if -i is None, calculate -i as 25% of total squares
		if args.ib is None:
			args.ib = ts // 4
		# Calculate open squares
		openSq = ts - args.assassin - args.ib
		## Make sure open squares is odd
		# One team has to go first, the other team has to have 
		# a -1 addvantage to make up for it.
		# If the number of open squares is even, 
		# make it odd by adding or subtracting one innocent
		if openSq < 3:
			sys.exit("Not enough squares in the grid.\n")
		if openSq % 2 == 0:
			if args.ib > openSq / 2:
				args.ib = args.ib - 1
				openSq = openSq +1
			else:
				args.ib = args.ib + 1
				openSq = openSq - 1
		# randomely pick red or blue to be 'first' the other 'second'
		sample = random.sample(["blue", "red"], 2)
		first = sample[0]
		second = sample[1]
		# assign first to get open squares /2 rounded up, and second openSq rounded down
		if first is "blue":
			args.blue = (openSq // 2) + 1
			args.red = openSq // 2
		else:
			args.red = (openSq // 2) + 1
			args.blue = openSq // 2

	# if exactly one of red or blue is none,
	# assign the one that is specified to be first, the other second
	# assign second to get first - 1 squares
	if args.blue is None or args.red is None:
		if args.red is not None:
			first = "red"
			args.blue = args.red - 1
		elif args.blue is not None:
			first = "blue"
			args.red = args.blue - 1
		# Calculate open squares
		if args.blue is not None and args.red is not None:
			openSq = ts - args.assassin - args.red - args.blue
		# if <0, error meesage
		if openSq < 0:
			sys.exit("Not enough squares in the grid.\n")
		if openSq == 0:
			print "There are no inocent by-standers on this map.\t" #TODO convert this to a proper warning
		if args.ib is None:
			args.ib = openSq
		if args.ib is not None and args.ib != openSq:
			sys.exit("This doesn't add up.")
	return args, first




def main():

	args = retrieve_args()

	if args.ss is not None:
		random.seed(args.ss)
		# later use random.sample(population, k) to sample without replacement

	args, ts = process_grid_size(args)
	args, first = process_square_types(args, ts)

	slotIds = np.array(random.sample(range(ts), ts))
	columns = sI_array % args.width
	rows = sI_array // args.width

	square_type = ["assassin"] * args.assassin + ["ib"] * args.ib + ["blue"] * args.blue + ["red"] * args.red
	types_dict = {slotIds[i]:square_type[i] for i in range(ts)}

	colors = ["black"] * args.assassin + ["tan"] * args.ib + ["blue"] * args.blue + ["red"] * args.red
	colors_dict = {slotIds[i]:colors[i] for i in range(ts)}

	


	print "total squares in grid: %d" % ts
	print args
	print "%s team to go first." % first




if __name__ == "__main__": main()
