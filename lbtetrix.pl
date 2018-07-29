#! /usr/bin/perl -w


#
# Author: Cesar Lombao
#
# Copyright (C) 2018 Cesar Lombao. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the GPLv3 License
#
# Mail: cesar.lombao@gmail.com
#

use strict;
use warnings;
use Data::Dumper;


use constant DEFAULT_SIZE_X => 500;
use constant DEFAULT_SIZE_Y => 600;




##############################################
##############################################
##### CLASS FOR PIECES  
##############################################
##############################################

package LBTetrix::piece;

use constant NUM_FIGURES => 6;

sub new{
	my $class = shift;
	
	my $self;
	$self->{type}   = 	int(rand(NUM_FIGURES)); # the figure
	$self->{xsize}		=	4;
	$self->{ysize}		=	4;
	
  bless($self,$class);
    $self->definefigure;
	my $k = int(rand(4)); # the orientation of the figure
	while($k--) { $self->rotate_right; }
	
return $self;
}

sub definefigure {
	my $self = shift;
	
	
	my $x; my $y;
	for($x=0;$x<$self->{xsize};$x++) {
		for ($y=0;$y<$self->{ysize};$y++) {
			$self->{cell}->{$x}{$y}{val} = 0;
			$self->{cell}->{$x}{$y}{color} = 0;
			
		}
	}
	
	# cell is a matrix 4x4 ( starts at 0 )
	if ($self->{type} == 0 ) {	# this is the stick figure
		$self->{cell}->{0}{1}{val} = 1;
		$self->{cell}->{1}{1}{val} = 1;
		$self->{cell}->{2}{1}{val} = 1;
		$self->{cell}->{3}{1}{val} = 1;
		$self->{cell}->{0}{1}{color} = 1;
		$self->{cell}->{1}{1}{color} = 1;
		$self->{cell}->{2}{1}{color} = 1;
		$self->{cell}->{3}{1}{color} = 1;
	}	
	elsif ($self->{type} == 1 ) { # this is the square
		$self->{cell}->{1}{1}{val} = 1;
		$self->{cell}->{2}{2}{val} = 1;
		$self->{cell}->{1}{2}{val} = 1;
		$self->{cell}->{2}{1}{val} = 1;	
		$self->{cell}->{1}{1}{color} = 2;
		$self->{cell}->{2}{2}{color} = 2;
		$self->{cell}->{1}{2}{color} = 2;
		$self->{cell}->{2}{1}{color} = 2;	
	}	 
	elsif ($self->{type} == 2) { # This is the T figure
		$self->{cell}->{1}{2}{val} = 1;
		$self->{cell}->{2}{2}{val} = 1;
		$self->{cell}->{3}{2}{val} = 1;
		$self->{cell}->{2}{1}{val} = 1;
		$self->{cell}->{1}{2}{color} = 3;
		$self->{cell}->{2}{2}{color} = 3;
		$self->{cell}->{3}{2}{color} = 3;
		$self->{cell}->{2}{1}{color} = 3;
	}
	elsif ($self->{type} == 3 ) { # This is the s  figure
		$self->{cell}->{1}{2}{val} = 1;
		$self->{cell}->{2}{2}{val} = 1;
		$self->{cell}->{2}{1}{val} = 1;
		$self->{cell}->{3}{1}{val} = 1;
		$self->{cell}->{1}{2}{color} = 4;
		$self->{cell}->{2}{2}{color} = 4;
		$self->{cell}->{2}{1}{color} = 4;
		$self->{cell}->{3}{1}{color} = 4;
	}	
	elsif ($self->{type} == 4  ) { # This the z figure 
		$self->{cell}->{1}{1}{val} = 1;
		$self->{cell}->{2}{1}{val} = 1;
		$self->{cell}->{2}{2}{val} = 1;
		$self->{cell}->{3}{2}{val} = 1;
		$self->{cell}->{1}{1}{color} = 5;
		$self->{cell}->{2}{1}{color} = 5;
		$self->{cell}->{2}{2}{color} = 5;
		$self->{cell}->{3}{2}{color} = 5;
	}
	elsif ($self->{type} == 5  ) { # This the L figure 
		$self->{cell}->{1}{2}{val} = 1;
		$self->{cell}->{2}{2}{val} = 1;
		$self->{cell}->{3}{2}{val} = 1;
		$self->{cell}->{3}{1}{val} = 1;
		$self->{cell}->{1}{2}{color} = 6;
		$self->{cell}->{2}{2}{color} = 6;
		$self->{cell}->{3}{2}{color} = 6;
		$self->{cell}->{3}{1}{color} = 6;
	}
	
}
 
sub rotate_right {
	my $self = shift;
	
	my $newcell;
	

	my $x; my $y; my $k;
	for($y=0;$y<$self->{ysize};$y++) {
		for ($x=0;$x<$self->{xsize};$x++) {
	    	$newcell->{$x}{$y}{val} = $self->{cell}->{$y}{$self->{xsize}-1-$x}{val};
	    	$newcell->{$x}{$y}{color} = $self->{cell}->{$y}{$self->{xsize}-1-$x}{color};
	    	
		}
	}	
	$self->{cell} = $newcell;
} 

sub rotate_left {
	my $self = shift;
	
    my $newcell;

	my $x; my $y; my $k;
	for($y=0;$y<$self->{ysize};$y++) {
		for ($x=0;$x<$self->{xsize};$x++) {
			$newcell->{$x}{$y}{val} = $self->{cell}->{$self->{ysize}-1-$y}{$x}{val};	
			$newcell->{$x}{$y}{color} = $self->{cell}->{$self->{ysize}-1-$y}{$x}{color};	

		}
	}	
    $self->{cell} = $newcell;
}
 
1;


##############################################
##############################################
##### CLASS FOR BOARD
##############################################
##############################################


package LBTetrix::board;


use Glib qw/TRUE FALSE/;

use constant XB => 10;
use constant YB => 20;

sub new{
	my $class = shift;
	
	
	my $self;
	$self->{xsize} = XB;
	$self->{ysize} = YB;
	$self->{lines} = 0;
	 
	my $x; my $y; my $k;
	for($y=0;$y<YB;$y++) {
		for ($x=0;$x<XB;$x++) {
			$self->{board}->{$x}{$y}{val} = 0;
			$self->{board}->{$x}{$y}{color} = 0;
		}
	}
	
  bless($self,$class);
    
return $self;
}

sub check_overlap {
	my $self = shift;
	my $p    = shift;
	my $xp	 = shift;
	my $yp 	 = shift;
	
	my $x; my $y;
	for ($y=$yp;$y<$yp+$p->{ysize};$y++) {
		next if (($y < 0 ) || ( $y >= $self->{ysize} ) );
		for($x=$xp;$x<$xp+$p->{xsize};$x++) {
			next if (($x < 0) || ( $x >= $self->{xsize} ));
			if ($p->{cell}->{$x-$xp}{$y-$yp}{val} + $self->{board}->{$x}{$y}{val} > 1) {
				return TRUE; # TRUE There is overlap
			}	
		}
	}
	return FALSE; # FALSE There is no overlap
	
}

sub check_outside {
	my $self 	= shift;
	my $p 		= shift;
	my $xp		= shift;
	my $yp		= shift;
	
	my $x; my $y; my $k;
	
	if ($xp < 0) {	
		for($y=0;$y<$p->{ysize};$y++) { $k += $p->{cell}->{ - $xp }{$y}{val}; }
		return TRUE if $k > 0; 
	}
	elsif ($xp > $self->{xsize} - $p->{xsize} ) {
		my $x = ( $self->{xsize} - $xp ) - 1;	
		for($y=0;$y<$p->{ysize};$y++) { $k += $p->{cell}->{$x}{$y}{val}; }
		return TRUE if $k > 0; 
	}
	
	return FALSE;
}


sub add_piece {
	my $self = shift;
	my $p    = shift;
	my $xp	 = shift;
	my $yp 	 = shift;
	
	my $x; my $y;

	for ($y=$yp;$y<$yp+$p->{ysize};$y++) {
		next if (  $y >= $self->{ysize} );
		for($x=$xp;$x<$xp+$p->{xsize};$x++) {
			next if ( $x >= $self->{xsize} );
			if ( exists $self->{board}->{$x}{$y} && $self->{board}->{$x}{$y}{val} == 0 ) {
				 $self->{board}->{$x}{$y}{val} = $p->{cell}->{$x-$xp}{$y-$yp}{val};
				 $self->{board}->{$x}{$y}{color} = $p->{cell}->{$x-$xp}{$y-$yp}{color};
				  
				
			}
		}
	}
	
		
}


sub remove_lines {
	my $self 	= 	shift;
	my $l = 0;
	
	my $x; my $y;
	my $xplus; my $yplus; my $f;
	for($y=0; $y < $self->{ysize} ; $y++){
		$f = 1;
		for($x=0; $x< $self->{xsize} ; $x++) {
		   if ($self->{board}->{$x}{$y}{val} == 0) { $f=0; }	  
		}
		if ($f==1) { # all this row is complete */
			$l++;
			for($yplus=$y;$yplus > 0;$yplus--) {
				for ($xplus=0; $xplus < $self->{xsize}; $xplus++) {
					$self->{board}->{$xplus}{$yplus}{val} = $self->{board}->{$xplus}{$yplus-1}{val}; 
					$self->{board}->{$xplus}{$yplus}{color} = $self->{board}->{$xplus}{$yplus-1}{color}; 
				}
			}
			for ($xplus=0; $xplus < $self->{xsize}; $xplus++) {
					$self->{board}->{$xplus}{0}{val} = 0; 
					$self->{board}->{$xplus}{0}{color} = 0;
			}
		}
	}	
	
 return $l;	
	
}

1;


##############################################
##############################################
##### CLASS FOR GAME
##############################################
##############################################


package LBTetrix::game;

use Glib qw/TRUE FALSE/;
use Gtk2;
use Cairo;
use Data::Dumper;


use constant SPEED_START => 550;
use constant SPEED_DELTA => 90;

sub new{
	my $class = shift;
	
	my $self;
	$self->{speed}		=	SPEED_START;
	$self->{points}		=	0;
	$self->{gameover}	=	0;
  bless($self,$class);
    
return $self;
}

sub create_frame {
	my $self	= shift;
    my $frame;
    	
    	my $x; my $y;
		for($y=0;$y<$self->{board}->{ysize};$y++){
			for($x=0;$x<$self->{board}->{xsize};$x++) {
				if ($x >= $self->{cpx} && $x< $self->{cpx}+$self->{cp}->{xsize} && $y >= $self->{cpy} && $y< $self->{cpy}+$self->{cp}->{ysize} ) {
					$frame->{$x}{$y}{val} = $self->{board}->{board}->{$x}{$y}{val} + $self->{cp}->{cell}->{$x-$self->{cpx}}{$y-$self->{cpy}}{val};
					$frame->{$x}{$y}{color} = $self->{board}->{board}->{$x}{$y}{color} + $self->{cp}->{cell}->{$x-$self->{cpx}}{$y-$self->{cpy}}{color};
					
				}
				else {
					$frame->{$x}{$y}{val} = $self->{board}->{board}->{$x}{$y}{val};
					$frame->{$x}{$y}{color} = $self->{board}->{board}->{$x}{$y}{color};
					
				}
			}
		}
		return $frame;
}

sub move_left {
	my $self	= shift;
	
	return if ($self->{gameover}==1);
	my $y; my $k=0;
	return if $self->{board}->check_overlap($self->{cp},$self->{cpx}-1,$self->{cpy});
	if ($self->{cpx} <= 0) {	
		for($y=0;$y<$self->{cp}->{ysize};$y++) { $k += $self->{cp}->{cell}->{ - $self->{cpx} }{$y}{val}; }
		return if $k > 0; 
	}
	$self->{cpx}--;
	$self->{cairoboard}->draw ( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} );
}

sub move_right {
	my $self	= shift;
	
	return if ($self->{gameover}==1);
	my $y; my $k=0;
	return if $self->{board}->check_overlap($self->{cp},$self->{cpx}+1,$self->{cpy});
	if ($self->{cpx} >= $self->{board}->{xsize} - $self->{cp}->{xsize} ) {
		my $x = ( $self->{board}->{xsize} - $self->{cpx} ) - 1;	
		for($y=0;$y<$self->{cp}->{ysize};$y++) {
			$k += $self->{cp}->{cell}->{$x}{$y}{val};
		}
		return if $k > 0; 
	}
	$self->{cpx}++;
	$self->{cairoboard}->draw ( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} );
}

sub move_down {
	my $self = shift;
	
	my $x; my $k=0;
	
		return if ($self->{gameover} == 1);
		if ($self->{board}->check_overlap($self->{cp},$self->{cpx},$self->{cpy}+1) == TRUE) {
			$self->newpiece;
			return FALSE;
		}
		if ($self->{cpy} >= $self->{board}->{ysize} - $self->{cp}->{ysize} ) {
			my $y = ( $self->{board}->{ysize} - $self->{cpy} ) - 1;	
			for($x=0;$x<$self->{cp}->{xsize};$x++) {
				$k += $self->{cp}->{cell}->{$x}{$y}{val};
			}
			if ($k > 0) {
				$self->newpiece;
				return FALSE;
			}
		}
		
		$self->{cpy}++;
		return TRUE;
}

sub rotate_left {
	my $self = shift;
	
	return if $self->{gameover} == 1;
	$self->{cp}->rotate_left;
	if ( $self->{board}->check_overlap($self->{cp},$self->{cpx},$self->{cpy}) == TRUE) {
		$self->{cp}->rotate_right;
		return;
	}
	if ( $self->{board}->check_outside($self->{cp},$self->{cpx},$self->{cpy}) == TRUE) {
		$self->{cp}->rotate_right;
		return;
	}
	
	$self->{cairoboard}->draw ( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} );
}


sub rotate_right {
	my $self = shift;
	
	return if $self->{gameover} == 1;
	$self->{cp}->rotate_right;
	if ( $self->{board}->check_overlap($self->{cp},$self->{cpx},$self->{cpy}) == TRUE) {
		$self->{cp}->rotate_left;
		return;
	}
	if ( $self->{board}->check_outside($self->{cp},$self->{cpx},$self->{cpy}) == TRUE) {
		$self->{cp}->rotate_left;
		return;
	}
	
	$self->{cairoboard}->draw ( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} );

}

sub free_fall {
	my $self = shift;
	
	return if ($self->{gameover} == 1);
	while($self->move_down) { $self->{cairoboard}->draw ( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} ) } ;
}

sub newpiece {
	my $self	= shift;
	
		$self->{board}->add_piece($self->{cp},$self->{cpx},$self->{cpy});

		
		$self->{lines} += $self->{board}->remove_lines;
		$self->{lineslabel}->set_text("Lines: ".$self->{lines});
		if ($self->{lines} > 10*$self->{level}) { $self->increase_level; }

		$self->{cp}			= 	$self->{np};
		$self->{np}			= 	LBTetrix::piece->new;
		$self->{points}		+=	1*$self->{level};
		$self->{blocks}++;
		$self->{pointslabel}->set_text("Points: ".$self->{points});
		$self->{numblockslabel}->set_text("Blocks: ".$self->{blocks});
		
		$self->{cpx}		= 	int(($self->{board}->{xsize} / 2) - ($self->{cp}->{xsize} / 2));
		$self->{cpy}    	=   -$self->{cp}->{ysize} + 1;
				
		$self->{caironp}->draw( $self->{np}->{cell}, $self->{np}->{xsize}, $self->{np}->{ysize} );

		if ( $self->{board}->check_overlap($self->{cp},$self->{cpx},$self->{cpy}+1) ) {
			$self->gameover;
		} 
}

sub gameover {
	my $self = shift;
		
		$self->{gameover} = 1;
		$self->set_timer;
		$self->{cairoboard}->drawgameover;
		if ( $self->{scores}->check_ishighscore($self->{points}) ) {
			

			my $dialog = Gtk2::Dialog->new ('Hi-Scores Board', undef, 'modal',
			'gtk-ok' => 'ok',  
			);

			my $hbox = Gtk2::HBox->new (FALSE, 6);
			$hbox->pack_start (Gtk2::Label->new ('Your name:'), TRUE, TRUE, 0);
			my $entry = Gtk2::Entry->new;
			$hbox->pack_start ($entry, TRUE, TRUE, 0);
			$hbox->show_all;

			$dialog->vbox->pack_start ($hbox, TRUE, TRUE, 0);
			$dialog->set_default_response ('ok');
			$entry->set_activates_default (TRUE);

			my $response = $dialog->run;

			$dialog->hide;
			
			$self->{scores}->add_hiscore($entry->get_text,$self->{points},$self->{level});
		}
		#$self->{scores}->print_hiscores;
		$self->{scores}->save_hiscores;
		
}

sub increase_level {
	my $self = shift;
	
		$self->{level}++;
		$self->{levellabel}->set_text("Level: ".$self->{level});
		$self->{speed} -= SPEED_DELTA;
		$self->{speedlabel}->set_text("Speed: ".$self->{speed});
		
		$self->set_timer;
}

sub start {
		my $self		= 	shift;
		my $scores		=  	shift;
		my $cairoboard	=	shift;
		my $caironp		=	shift;
		my $levellabel	=	shift;
		my $pointslabel	=	shift;
		my $speedlabel	= 	shift;
		my $numblockslabel = shift;
		my $lineslabel	= 	shift;
		
			$self->{scores}		=  $scores;
		    $self->{pause}		=   0;
			$self->{board} 		= 	LBTetrix::board->new;
			$self->{cp}			= 	LBTetrix::piece->new;
			$self->{level}		=	1;
			$self->{lines}		=   0;
			$self->{np}			= 	LBTetrix::piece->new;
			$self->{speed}		=	SPEED_START;
			$self->{points}		=	0;
			$self->{cpx}		= 	int(($self->{board}->{xsize} / 2) - ($self->{cp}->{xsize} / 2));
			$self->{cpy}    	=   -$self->{cp}->{ysize};
			$self->{gameover}	=	0;
            $self->{blocks}		=   0;
            
			$self->{cairoboard} = $cairoboard;
			$self->{caironp}	= $caironp;
			$self->{levellabel}	= $levellabel;
			$self->{pointslabel}	= $pointslabel;
			$self->{speedlabel}		= $speedlabel;
		    $self->{numblockslabel} = $numblockslabel;
		    $self->{lineslabel} = $lineslabel;
		    	
			$self->{caironp}->draw( $self->{np}->{cell}, $self->{np}->{xsize}, $self->{np}->{ysize} );
			$self->{levellabel}->set_text("Level: ".$self->{level});   
			$self->{pointslabel}->set_text("Points: ".$self->{points});   
			$self->{speedlabel}->set_text("Speed: ".$self->{speed});   
			$self->{lineslabel}->set_text("Lines: ".$self->{lines});   
			
			$self->{numblockslabel}->set_text("Blocks: ".0);   
			
			$self->set_timer;

}


sub pause {
	my $self = shift;
	
		return if $self->{gameover} == 1;
		if ($self->{pause} ) { $self->{pause} = 0;	}
		else				 { $self->{pause} = 1; $self->{cairoboard}->drawpause; }
		$self->set_timer;
}

sub set_timer {
	my $self = shift;	


	    if ($self->{timeout}) {
			Glib::Source->remove($self->{timeout}) if $self->{timeout};
			$self->{timeout} = undef;
		}
		return if ($self->{gameover});
		return if ($self->{pause});
	    $self->{timeout} = Glib::Timeout->add($self->{speed}, 
	       sub {
			   $self->move_down;
			   if (!$self->{gameover}) {
					$self->{cairoboard}->draw( $self->create_frame, $self->{board}->{xsize}, $self->{board}->{ysize} );
					return TRUE;
			   }
			   else {
			     return FALSE;
			   }
			   }, $self );	
}




1;


##############################################
##############################################
##### PACKAGE THE CAIRO BOARD  
##############################################
##############################################

package LBTetrix::cairoboard;

use Glib qw/TRUE FALSE/;
use Gtk2;
use Cairo;
use Data::Dumper;

# There is a problem here this 500 and 600 are the default x y size, it should
# be related to those constants.
use constant SIZE_X     => 0.1;
use constant SIZE_Y     => 0.05;


use Glib::Object::Subclass
	Gtk2::DrawingArea::,
	signals => {
		expose_event => \&expose,
	};


sub expose
{
	my ($self, $event) = @_;

	my $cr = Gtk2::Gdk::Cairo::Context->create($self->window);
	$cr->rectangle (0,
			0,
			$self->allocation->width,
			$self->allocation->height);
	$cr->clip;
	$cr->scale($self->allocation->width, $self->allocation->height);
	$cr->paint;
	
	if ($self->{xb}) {
		my $x; my $y; 
		
		for($y=0; $y < $self->{yb} ; $y++){
			for($x=0; $x < $self->{xb} ; $x++) {
				if ($self->{board}->{$x}{$y}{val} == 1) {
					$cr->rectangle($x*SIZE_X,$y*SIZE_Y,SIZE_X-0.008,SIZE_Y-0.005);
					if  ( $self->{board}->{$x}{$y}{color} == 1 ) { 	$cr->set_source_rgba (0.7, 0, 0.1, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 2 ) { 	$cr->set_source_rgba (0.3, 0.5, 0.2, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 3 ) { 	$cr->set_source_rgba (0.1, 0.7, 0.1, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 4 ) { 	$cr->set_source_rgba (0.2, 0.5, 0.5, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 5 ) { 	$cr->set_source_rgba (0.6, 0.1, 0.9, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 6 ) { 	$cr->set_source_rgba (0.7, 0.7, 0.4, 0.8); }
					$cr->fill;
				}	
			}
		}
	}
	return FALSE;
}


# This only trigger the expose event, stores the board, and then
# the expose method will draw the board. I do not like the way cairo+gtk2 works
sub draw {
	my $self 	= shift;
	my $board 	= shift;
	my $xb 		= shift;
	my $yb 		= shift;
	

		$self->{board} 	= $board;
		$self->{xb} 	= $xb;
		$self->{yb} 	= $yb;
		my $alloc = $self->allocation;
		my $rect = Gtk2::Gdk::Rectangle->new(0, 0, $alloc->width, $alloc->height);
		$self->window->invalidate_rect($rect, FALSE);

}


sub drawpause {
	my $self 	= shift;
	

		my $alloc = $self->allocation;
		my $layout = $self->create_pango_layout ("PAUSE");
		$self->window->draw_rectangle
	    		($self->get_style->base_gc ($self->state),
			     TRUE, 0, $self->allocation->height/3, $self->allocation->width, $self->allocation->height/3);

		my ($text_width, $text_height) = $layout->get_pixel_size;
		
		$self->window->draw_layout
			 ($self->get_style->text_gc ($self->state),
			 ($self->allocation->width - $text_width) / 2,
			 ($self->allocation->height - $text_height) / 2,
			 $layout);
		
}

sub drawgameover {
	my $self 	= shift;
	

		my $alloc = $self->allocation;
		my $layout = $self->create_pango_layout ("GAME OVER");
		$self->window->draw_rectangle
	    		($self->get_style->base_gc ($self->state),
			     TRUE, 0, $self->allocation->height/3, $self->allocation->width, $self->allocation->height/3);

		my ($text_width, $text_height) = $layout->get_pixel_size;
		
		$self->window->draw_layout
			 ($self->get_style->text_gc ($self->state),
			 ($self->allocation->width - $text_width) / 2,
			 ($self->allocation->height - $text_height) / 2,
			 $layout);
		
}


sub INIT_INSTANCE {
	my $self = shift;
}

sub FINALIZE_INSTANCE {
	my $self = shift;
}


1;



##############################################
##############################################
##### PACKAGE THE CAIRO NEXT PIECE 
##############################################
##############################################

package LBTetrix::caironp;

use Glib qw/TRUE FALSE/;
use Gtk2;
use Cairo;
use Data::Dumper;

# There is a problem here this 500 and 600 are the default x y size, it should
# be related to those constants.
use constant SIZE_X     => 0.18;
use constant SIZE_Y     => 0.20;


use Glib::Object::Subclass
	Gtk2::DrawingArea::,
	signals => {
		expose_event => \&expose,
	};


sub expose
{
	my ($self, $event) = @_;


	my $cr = Gtk2::Gdk::Cairo::Context->create($self->window);
	$cr->rectangle (0,
			0,
			$self->allocation->width,
			$self->allocation->height);
	$cr->clip;
	$cr->scale($self->allocation->width, $self->allocation->height);
	$cr->paint;
	
	if ($self->{xb}) {
		my $x; my $y; 
		
		for($y=0; $y < $self->{yb} ; $y++){
			for($x=0; $x < $self->{xb} ; $x++) {
				if ($self->{board}->{$x}{$y}{val} == 1) {
					$cr->rectangle($x*SIZE_X,$y*SIZE_Y,SIZE_X-0.006,SIZE_Y-0.007);  
					if  ( $self->{board}->{$x}{$y}{color} == 1 ) { 	$cr->set_source_rgba (0.7, 0, 0.1, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 2 ) { 	$cr->set_source_rgba (0.3, 0.5, 0.2, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 3 ) { 	$cr->set_source_rgba (0.1, 0.7, 0.1, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 4 ) { 	$cr->set_source_rgba (0.2, 0.5, 0.5, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 5 ) { 	$cr->set_source_rgba (0.6, 0.1, 0.9, 0.8); }
					elsif  ( $self->{board}->{$x}{$y}{color} == 6 ) { 	$cr->set_source_rgba (0.7, 0.7, 0.4, 0.8); }
					$cr->fill;
				}	
			}
		}
	}
	return FALSE;
}


# This only trigger the expose event, stores the board, and then
# the expose method will draw the board. I do not like the way cairo+gtk2 works
sub draw {
	my $self 	= shift;
	my $board 	= shift;
	my $xb 		= shift;
	my $yb 		= shift;
	
		$self->{board} 	= $board;
		$self->{xb} 	= $xb;
		$self->{yb} 	= $yb;
		my $alloc = $self->allocation;
		my $rect = Gtk2::Gdk::Rectangle->new(0, 0, $alloc->width, $alloc->height);
		$self->window->invalidate_rect($rect, FALSE);

}


sub INIT_INSTANCE {
	my $self = shift;
}

sub FINALIZE_INSTANCE {
	my $self = shift;
}


1;



##########################################
##########################################
# SCORES PACKAGE
##########################################
##########################################
package LBTetrix::scores;

use Glib qw/TRUE FALSE/; 
use File::Basename;
use File::Path qw/make_path/;

use constant HIGH_SCORES_FILE => $ENV{"HOME"}."/.scores/lbtetrix.dat";
use constant MAX_HISCORES	  => 10;

sub new {

 my $class 	= shift;
 my $vbox	= shift;
	my $self = { };
	
	
	$self->{vbox} = $vbox;
	
	my $a;
	for($a=1;$a<=MAX_HISCORES;$a++) {
		$self->{$a}->{name} ="XXX";
		$self->{$a}->{level} ="1";
		$self->{$a}->{points} ="0";
	}
	
	make_path (dirname(HIGH_SCORES_FILE));
    open FILE, ">>".HIGH_SCORES_FILE or die $!; # create if not there
    close FILE;
    
    open FILE, "<".HIGH_SCORES_FILE or die $!;
    while(<FILE>) {
		chomp;
		my ($pos,$name,$level,$points) = split(/,/);
		$pos = $pos + 0;
		$self->{$pos}->{name} = $name;
		$self->{$pos}->{points} = $points;
		$self->{$pos}->{level} = $level;
		
	}
    close(FILE);	

	$self->{label1}		= Gtk2::Label->new ("1::".$self->{1}->{name}.": ".$self->{1}->{points}." Level".$self->{1}->{level});
	$self->{label2}		= Gtk2::Label->new ("2::".$self->{2}->{name}.": ".$self->{2}->{points}." Level".$self->{2}->{level});
	$self->{label3}		= Gtk2::Label->new ("3::".$self->{3}->{name}.": ".$self->{3}->{points}." Level".$self->{3}->{level});
	$self->{label4}		= Gtk2::Label->new ("4::".$self->{4}->{name}.": ".$self->{4}->{points}." Level".$self->{4}->{level});
	
	
	$self->{vbox}->add($self->{label1});
	$self->{vbox}->add($self->{label2});
	$self->{vbox}->add($self->{label3});
	$self->{vbox}->add($self->{label4});
	
	
    
    bless($self,$class);
    
return $self;
}

sub check_ishighscore {
	my $self = shift;
	my $points = shift;

	my $a;
	for ($a=1;$a<=MAX_HISCORES;$a++) {
		if ($self->{$a}->{points} < $points) {
			return TRUE;
		}
	}
	
	return FALSE;
}

sub add_hiscore {
	my $self = shift;
	my $name = shift;
	my $points = shift;
	my $level  = shift;
	
	
	my $a; my $pos=0;
	for($a=1;$a<=MAX_HISCORES;$a++) {
		if ($points > $self->{$a}->{points}) {
			$pos = $a; last;
		}
	}
	
	if ($pos != 0) {
		my $b;
		for($b=MAX_HISCORES; $b>$pos; $b--) {
			$self->{$b}->{name} = $self->{$b-1}->{name};
			$self->{$b}->{points} = $self->{$b-1}->{points};
			$self->{$b}->{level} = $self->{$b-1}->{level};				
		}
			
		$self->{$pos}->{name} = $name;
		$self->{$pos}->{points} = $points;
		$self->{$pos}->{level} = $level;				
	}	
	
}

sub print_hiscores {
	my $self 	=	shift;
	
	my $a;
	for($a=1;$a<MAX_HISCORES;$a++) {
		print($self->{$a}->{name}.":".$self->{$a}->{level}." ".$self->{$a}->{points}."\n");
	}
}

sub save_hiscores {
	my $self 	=	shift;
	
	open FILE, ">".HIGH_SCORES_FILE or die $!;
    
	my $a;
	for($a=1;$a<MAX_HISCORES;$a++) {
		print FILE $a.",".$self->{$a}->{name}.",".$self->{$a}->{level}.",".$self->{$a}->{points}."\n";
	}
	
	$self->{label1}->set_text( "1::".$self->{1}->{name}.": ".$self->{1}->{points}." Level".$self->{1}->{level} );
	$self->{label2}->set_text( "2::".$self->{2}->{name}.": ".$self->{2}->{points}." Level".$self->{2}->{level} );
	$self->{label3}->set_text( "3::".$self->{3}->{name}.": ".$self->{3}->{points}." Level".$self->{3}->{level} );
	$self->{label4}->set_text( "4::".$self->{4}->{name}.": ".$self->{4}->{points}." Level".$self->{4}->{level} );
	
	
    close(FILE);	
    
}

sub showtop {
	my $self =	shift;
	
			my $dialog = Gtk2::Dialog->new ('Hall of Fame', undef, 'modal',	'gtk-ok' => 'ok');
		
			my $a;
			my $frame = Gtk2::Frame->new("The best 10 ");
			$frame->set_size_request(360,400);
			
			my $vbox = Gtk2::VBox->new (FALSE, 6);
			for ($a=1;$a<MAX_HISCORES;$a++) {
				my $text = $a."::".$self->{$a}->{name}."  Score:".$self->{$a}->{points}." Level:".$self->{$a}->{level};
				$vbox->pack_start (Gtk2::Label->new($text), TRUE, TRUE, 0);
			}
			$vbox->show_all;
			$frame->add($vbox);
			$frame->show_all;
			$dialog->vbox->pack_start ($frame, TRUE, TRUE, 0);
			$dialog->set_default_response ('ok');
			
			my $response = $dialog->run;

			$dialog->hide;
}

1;



##########################################
##########################################
# MAIN PACKAGE
##########################################
##########################################


package main;


use warnings;
use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/; 
use Gtk2::SimpleMenu;


my $game 		= LBTetrix::game->new;
my $cairoboard 	= LBTetrix::cairoboard->new;
my $caironp		= LBTetrix::caironp->new;

my $levellabel 	= Gtk2::Label->new ();
my $pointslabel	= Gtk2::Label->new ();
my $speedlabel 	= Gtk2::Label->new ();
my $numblockslabel 	= Gtk2::Label->new ();
my $lineslabel		= Gtk2::Label->new ();

my $vboxscores = Gtk2::VBox->new(TRUE,5);
my $scores	= LBTetrix::scores->new($vboxscores);
 
#standard window creation, placement, and signal connecting
my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub 	{ Gtk2->main_quit; });
$window->signal_connect( "destroy" => sub 		{ Gtk2->main_quit; });
$window->set_border_width(5);
$window->set_position('center_always');
$window->signal_connect('key-press-event' => sub {
								my ($widget,$event,$parameter)= @_;
								my $key_nr = $event->keyval();
								if ($key_nr == 65361) 	{ $game->move_left; }
								elsif ($key_nr == 65363) 	{ $game->move_right;}
								elsif ($key_nr == 65362) 	{ $game->rotate_right;}
								elsif ($key_nr == 65364) 	{ $game->rotate_left;}
								elsif ($key_nr == 32) 		{ $game->free_fall; }
								elsif ($key_nr == 112) 		{ $game->pause; }

								return FALSE;
								});

# The menu
	my $menu_tree = [
		_Game  => {
			item_type  => '<Branch>',
			children => [
				_New       => {
					callback => sub { $game->start($scores,$cairoboard,$caironp,$levellabel,$pointslabel,$speedlabel,$numblockslabel,$lineslabel); }, 
				},		
				_Pause      => {
					callback => sub { $game->pause; },
				},

				_Exit      => {
					callback => sub { Gtk2->main_quit; },
					accelerator => '<ctrl>E',
				},
			],
		},
		_Scores  => {
			item_type => '<Branch>',
			children => [
				_Top  => {
					callback => sub { $scores->showtop },
				},

			],
		},
		_Help  => {
			item_type => '<Branch>',
			children => [
				_Introduction => {
					callback => \&callback,
				},
			],
		},
	];

	my $menu = Gtk2::SimpleMenu->new(
				menu_tree        => $menu_tree,
				user_data        => $game,
			);



#this  will return the bulk of the gui

	my $vbox = Gtk2::VBox->new(FALSE,5);
	$vbox->set_size_request (DEFAULT_SIZE_X, DEFAULT_SIZE_Y);
	$vbox->pack_start($menu->{widget},FALSE,FALSE,0);
	
	my $hbox = Gtk2::HBox->new(FALSE, 0);
    $hbox->set_border_width(8);
	$vbox->add($hbox);
	
    my $vboxpanel = Gtk2::VBox->new(FALSE,5);
	$vboxpanel->set_size_request (160, 200);
	$caironp->set_size_request(80,80);
	$vboxpanel->pack_start($caironp,FALSE,FALSE,0);
	
	my $framenow = Gtk2::Frame->new("Playing now");
	$framenow->set_size_request(160,100);
	my $vboxlabels = Gtk2::VBox->new(TRUE,5);
	$framenow->add($vboxlabels);	
    $vboxlabels->add($levellabel);
    $vboxlabels->add($pointslabel);
    $vboxlabels->add($numblockslabel);
    $vboxlabels->add($lineslabel);
    $vboxlabels->add($speedlabel);

	my $framescores = Gtk2::Frame->new("Hi-Scores");    
    $framescores->set_size_request(160,100);
	$framescores->add($vboxscores);	
    
    
    $vboxpanel->add($framenow);
    $vboxpanel->add($framescores);
    
	$hbox->pack_start($vboxpanel,FALSE,FALSE,20);
	$hbox->add($cairoboard);	
	
	$vbox->show_all();
	

#add and show the vbox
$window->add($vbox);
$window->show();

#our main event-loop
Gtk2->main();

