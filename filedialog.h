#ifndef FILEDIALOG_H
#define FILEDIALOG_H

#include <QMainWindow>
#include <QFileDialog>

class FileDialog : public QMainWindow
{
    Q_OBJECT
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
public:
    explicit FileDialog(QWidget *parent = nullptr);

    const QString &filePath() const;
    void setFilePath(const QString &newFilePath);

public slots:
    void openFile();

signals:

    void filePathChanged();

private:
    QString m_filePath;
};

#endif // FILEDIALOG_H
