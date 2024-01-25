#!/usr/bin/perl
# Copyright (C) Matthew Anderson

use 5.000;
use strict;
use warnings;
use XML::Twig;

# Check for provided input and output filenames
if (@ARGV != 2) {
    die "Error: Usage: $0 <input_file> <output_file>\n[0%] Process Could Not Be Completed\n";
}

# Get input and output filenames
my $input_file  = $ARGV[0];
my $output_file = $ARGV[1];

# Create an XML::Twig object
my $twig = XML::Twig->new(
    pretty_print => 'indented', # Yes, indent
);

# Parse the input file
$twig->parsefile($input_file);

# Modify XML elements to match the new format
my $svg_element = $twig->root;
$svg_element->set_tag('svg');

# TODO: Improve this:
# Construct xmlns attribute with viewBox if it exists
my $xmlns_value = 'http://www.w3.org/2000/svg';
if ($svg_element->att_exists('viewBox')) {
    my $viewbox_value = $svg_element->att('viewBox');
    $xmlns_value .= " viewBox=\"$viewbox_value\"";
    $svg_element->del_att('viewBox');  # Remove viewBox attribute as it's now part of xmlns
}
$svg_element->set_att('xmlns', $xmlns_value);

# Remove attributes from the root element
$svg_element->del_atts; # purge

# Change attribute names and values to match the second format
foreach my $bkg_element ($twig->find_nodes('//g[@id="a"]')) {
    $bkg_element->set_tag('g') if $bkg_element->att_exists('id');
    $bkg_element->set_att('data-name', "bkg") if $bkg_element->att_exists('data-name');

# Set x and y attributes to 0 if they are missing
    foreach my $rect_element ($bkg_element->children('rect')) {
        $rect_element->set_att('x', 0) unless $rect_element->has_att('x');
        $rect_element->set_att('y', 0) unless $rect_element->has_att('y');
	}

}

# Print the modified XML content to the output file
$twig->print_to_file($output_file);

print "[100%] SVG XML converted from the first format to the second format.\n";
