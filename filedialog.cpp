#include "filedialog.h"
#include <QFileDialog>

FileDialog::FileDialog(QWidget *parent)
    : QMainWindow{parent}
{
}

const QString &FileDialog::filePath() const
{
    return m_filePath;
}

void FileDialog::setFilePath(const QString &newFilePath)
{
    if (m_filePath == newFilePath)
        return;
    m_filePath = newFilePath;
    emit filePathChanged();
}

void FileDialog::openFile() {
    QString newFilePath;
    QString oldFilePath;

    newFilePath = QFileDialog::getOpenFileName();
    oldFilePath = filePath();

    if(newFilePath == "" && oldFilePath != "") {
        return;
    }
    setFilePath(newFilePath);
}
