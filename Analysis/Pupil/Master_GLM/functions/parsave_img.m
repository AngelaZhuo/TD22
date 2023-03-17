function parsave_img(Save_Directory, figName, FIG, PNG, PDF)
    if FIG
        saveas(gcf, Save_Directory + "/" + replace(figName, ".", "") + ".fig") 
    end
    if PNG
        saveas(gcf, Save_Directory + "/" + replace(figName, ".", "") + ".png")
    end
    if PDF
        saveas(gcf, Save_Directory + "/" + replace(figName, ".", "") + ".pdf") 
    end
end