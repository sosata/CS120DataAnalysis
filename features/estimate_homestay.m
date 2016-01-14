function homestay = estimate_homestay(lab, lab_home)

homestay = sum(lab==lab_home)/length(lab); % probbality of staying in the most populous cluster

end