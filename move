using UnityEngine;
using System.Collections;

public class CharacterScript : MonoBehaviour
{
    public float patrolRadius = 10f; // 巡邏半徑
    public float speed = 5f; // 移動速度
    public float dodgeDistance = 3f; // 閃避距離

    private Vector3 startingPosition; // 初始位置
    private Vector3 destination; // 巡邏目的地
    private bool isDodging = false; // 是否正在閃避
    private GameObject[] enemies; // 敵人陣列

    void Start()
    {
        startingPosition = transform.position; // 記錄初始位置
        SetRandomDestination(); // 設定隨機目的地
        enemies = GameObject.FindGameObjectsWithTag("Enemy"); // 取得所有敵人
    }

    void Update()
    {
        if (!isDodging)
        {
            Patrol(); // 巡邏
        }
    }

    void Patrol()
    {
        // 如果到達目的地，設定新的目的地
        if (Vector3.Distance(transform.position, destination) < 1f)
        {
            SetRandomDestination();
        }

        // 移動向目的地
        transform.position = Vector3.MoveTowards(transform.position, destination, speed * Time.deltaTime);

        // 檢查是否有敵人在攻擊範圍內，如果是，進行閃避
        foreach (GameObject enemy in enemies)
        {
            if (Vector3.Distance(transform.position, enemy.transform.position) < dodgeDistance)
            {
                Dodge(enemy.transform.position);
            }
        }
    }

    void SetRandomDestination()
    {
        // 設定目的地為在巡邏範圍內的一個隨機位置
        destination = startingPosition + Random.insideUnitSphere * patrolRadius;
        destination.y = startingPosition.y;
    }

    void Dodge(Vector3 enemyPosition)
    {
        // 閃避到敵人背後
        Vector3 dodgeDirection = (transform.position - enemyPosition).normalized;
        Vector3 dodgePosition = enemyPosition + dodgeDirection * dodgeDistance;
        transform.position = dodgePosition;

        isDodging = true;

        // 在0.5秒後結束閃避
        StartCoroutine(EndDodge(0.5f));
    }

    IEnumerator EndDodge(float delay)
    {
        yield return new WaitForSeconds(delay);

        isDodging = false;
    }
}
