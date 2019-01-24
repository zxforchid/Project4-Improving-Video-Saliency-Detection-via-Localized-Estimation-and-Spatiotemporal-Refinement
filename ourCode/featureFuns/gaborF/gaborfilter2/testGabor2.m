 
clear all;close all;clc

im = imread('00000001.jpg'); 
im = rgb2gray(im); 
bank = do_createfilterbank(size(im)); 
result = do_filterwithbank(im,bank);