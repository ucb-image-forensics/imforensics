function djc_detector(img_path)
    result = analyze_double_jpeg(img_path);
    imwrite(result.aligned, [img_path '.djc.aligned.png'])
    imwrite(result.unaligned, [img_path '.djc.unaligned.png'])
return
