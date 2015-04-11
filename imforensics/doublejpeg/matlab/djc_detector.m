function djc_detector(img_path)
    result = analyze_double_jpeg(img_path);

    overlay_feature_mask(result.aligned, img_path, '.djca.png');
    overlay_feature_mask(result.unaligned, img_path, '.djcu.png');
return
